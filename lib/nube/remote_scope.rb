module RemoteScope

  extend ActiveSupport::Concern
  include RemoteRelation

  class_methods do

    def node(opts={})
      opts[:identity] = IDENTITY_SITE if not opts.has_key?(:identity) and defined?(IDENTITY_SITE)
      "#{self}Relation".constantize.new(self, { site_options: opts })
    end

    def build_params keys, values
      hash = Hash[keys.map{|k| [k, values[keys.index(k)]] }]
      hash.empty? ? nil : hash
    end

    def scope(name, opts={})
      scope_name = opts.has_key?(:remote_scope) ? opts[:remote_scope] : name

      define_singleton_method name do |*values|
        scope_params = build_params(opts[:using].to_a, values)
        "#{self}Relation".constantize.new(self, { scopes: {scope_name => scope_params} })
      end

      "#{self}Relation".constantize.class_eval do
        define_method name do |*values|
          scope_params = xmodel.build_params(opts[:using].to_a, values)
          tap{|s| s.params.deep_merge!({ scopes: {scope_name => scope_params} })}
        end
      end
    end

  end
end