module LocalAssociation

  extend ActiveSupport::Concern
  include RemoteRelation

  class_methods do
    def reflection(rel=nil)
      _reflection = self.reflect_on_all_associations.map do |assc|
        { type: assc.class.name[/([^::]+)Reflection\z/,1].underscore,
          klass: (assc.options[:polymorphic] ?  nil : assc.klass),
          rel: assc.name,
          foreign_key: assc.foreign_key }
      end
      _reflection += remote_reflections.to_a
      rel.nil? ? _reflection : _reflection.select{|r| r[:rel] == rel }.first
    end

    def create_callback_for_dependent_destroy_or_nullify rel, opts
      if opts[:dependent] == :destroy
        after_destroy "destroy_#{rel}"

        define_method "destroy_#{rel}" do
          send(rel).destroy_all
        end
      elsif opts[:dependent] == :nullify
        after_destroy "nullify_#{rel}"

        define_method "nullify_#{rel}" do
          send(rel).update_all(self.class.foreign_key(rel) => nil)
        end
      end
    end

  end
end
