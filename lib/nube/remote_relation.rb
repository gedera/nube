module RemoteRelation

  extend ActiveSupport::Concern

  included do
    Object.const_set(
      "#{self.to_s.split('::').last}Relation", Class.new do
        attr_accessor :xmodel, :params

        def initialize(xmodel, params={})
          @params = params
          @xmodel = xmodel
        end

        def find(*ids)
          @params.merge!({ where: [{id: ids.flatten}] })
          resources = all
          (resources.size > 1) ? resources : resources.first
        end

        def controller_name
          @xmodel.name.pluralize.underscore
        end

        def destroy_all(where={}, relations={})
          @xmodel.delete(@params.delete(:site_options).merge({ action: 'destroy_all' }), { where: [where].flatten }).map{|attrs| @xmodel.new(attrs, false) }
        end

        def update_all(changes={}, where={}, relations={})
          changes.each do |attrib, value|
            # change true and false by 1 or 0 becouse params are sent as string
            changes[attrib] = (value ? 1 : 0) if !!value == value
          end
          @xmodel.put(@params.delete(:site_options).merge({ action: 'update_all' }), { changes: changes, where: [where].flatten }).first
        end

        def empty_attributes
          @xmodel.get(@params.delete(:site_options).merge({ action: 'empty_attributes' })).first
        end

        def count
          @xmodel.get(@params.delete(:site_options).merge({ action: 'count' }), @params).first.to_i
        end

        def all
          @xmodel.get(@params.delete(:site_options), @params).map{|attributes| @xmodel.new(attributes, false) }
        end

        def first
          (@params[:order] ||= []) << { id: :asc }
          @params[:limit] = 1
          all.first
        end

        def last
          (@params[:order] ||= []) << { id: :desc }
          @params[:limit] = 1
          all.last
        end

        def joins(*models)
          if @xmodel.same_class?(models)
            params[:joins]= [] unless params.has_key?(:joins)
            tap{ |s| s.params[:joins] += models }
          else
            raise 'Errors: Some class is not Remote Resource'
          end
        end

        def create(attrs={})
          obj = @xmodel.new(attrs)
          obj.save
          obj
        end

        def where(conditions); tap{|s| (s.params[:where] || s.params[:where] = []) << conditions}; end

        def order(conditions); tap{|s| (s.params[:order] || s.params[:order] = []) << conditions}; end

        def limit(number); tap{|s| s.params[:limit] = number }; end

        def offset(number); tap{|s| s.params[:offset] = number }; end

        def page(size=1)
          @page = size
          limit(25) unless @params.has_key?(:limit)
          calculate_offset
        end

        def per(size=25)
          @page ||= 1
          limit(size)
          calculate_offset
        end

        def calculate_offset; offset(@params[:limit] * (@page - 1)); end

        def paginate(value={})
          value.has_key?(:page)     ? page(value[:page])    : page
          value.has_key?(:per_page) ? per(value[:per_page]) : per
        end

        def search(params={}); tap{|s| s.params[:search] = params }; end

        alias_method :ransack, :search

        def massive_transactions(transaction, method, action)
          @xmodel.send(method, @params.delete(:site_options).merge({ action: action }), @params.merge(transaction: transaction))
        end

        def massive_creation(transaction); massive_transactions(transaction, 'post', 'massive_creation', site_options); end

        def massive_sum(transaction); massive_transactions(transaction, 'put', 'massive_sum', site_options); end

        def massive_update(transaction); massive_transactions(transaction, 'put', 'massive_update', site_options); end

        def method_missing(name, *args, &block)
          all.send(name, *args, &block)
        end

      end
    )
  end

  # module ClassMethods
  class_methods do
    @@reflections = {}

    def same_class?(*relations)
      reflection.select{|r| relations.include?(r[:rel]) }.collect{|r| r[:klass] }.map{|k| k.superclass == self.superclass }.all?
    end

    # Need implementation in whole relations
    def check_relation(relation)
      (relation - reflection.map{|r| r[:rel] }).empty?
    end

    def remote_has_many(rel, opts={})
      add_reflection(:has_many, rel, opts)
      self.class_eval do
        define_method rel do
          return polymorphic_has_many(rel, opts) if opts.has_key?(:as)
          if opts.has_key?(:through)
            through_class = opts[:through].to_s.singularize.camelize.constantize
            klass = through_class.xclass(rel)
            through_obj = send(opts[:through])
            through_rel = through_class.reflection(rel)

            collect_through = (through_rel[:type] == :belong_to) ? through_rel[:foreign_key] : "id"
            foreign_key     = (through_rel[:type] == :belong_to) ? "id"                      : through_rel[:foreign_key]

            ids = through_obj.is_a?(through_class) ? [through_obj.send(collect_through)] : through_obj.all.collect(&"{collect_through}".to_sym)

            klass.where(foreign_key => ids)
          else
            self.class.xclass(rel).where(self.class.foreign_key(rel) => self.id)
          end
        end
      end
    end

    def remote_belongs_to(rel, opts={})
      add_reflection(:belongs_to, rel, opts)

      self.class_eval do
        define_method rel do
          return polymorphic_belongs_to(rel, opts) if opts.has_key?(:polymorphic)
          class_rel = self.class.xclass(rel)
          foreign_key = self.class.foreign_key(rel)
          send(foreign_key).nil? ? nil : class_rel.find(send(foreign_key))
        end
      end
    end

    def remote_has_one(rel, opts={})
      add_reflection(:has_one, rel, opts)
      self.class_eval do
        define_method rel do
          return polymorphic_has_one(rel, opts) if opts.has_key?(:as)

          if opts.has_key?(:through)
            send(opts[:through]).send(rel)
          else
            self.class.xclass(rel).where(self.class.foreign_key(rel) => self.id).first
          end
        end
      end
    end

    def add_reflection(type, rel, opts)
      return if opts.has_key?(:foreign_key) or opts.has_key?(:polymorphic)
      klass = opts.has_key?(:class_name) ? opts[:class_name].constantize : rel.to_s.singularize.camelize.constantize
      unless opts.has_key?(:through)
        foreign_key = if opts.has_key?(:foreign_key)
                        opts[:foreign_key]
                      else
                        (type == :belongs_to) ? "#{rel.to_s.singularize}_id" : "#{self.to_s.singularize.underscore}_id"
                      end
        (@@reflections[self] ||= []) << {type: type, rel: rel, klass: klass, foreign_key: foreign_key}
      end
    end

    def remote_reflections; @@reflections[self]; end


    def foreign_key(rel)
      reflection(rel)[:foreign_key]
    end

    def xclass(rel)
      reflection(rel)[:klass]
    end
  end

  def polymorphic_belongs_to(rel, opts={})
    self.send("#{rel}_type").constantize.find(self.send("#{rel}_id"))
  end

  def polymorphic_has_one(rel, opts={})
    polymorphic_has_many(rel, opts={}).first
  end

  def polymorphic_has_many(rel, opts={})
    self.class.xclass(rel).where("#{opts[:as]}_id" => self.id, "#{opts[:as]}_type" => self.class.to_s)
  end

end
