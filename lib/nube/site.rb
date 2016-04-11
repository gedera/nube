module Site

  extend ActiveSupport::Concern

  class_methods do
    # Methods to override
    def site(identity, controller_name, action_name, object_id, opts={})
      # Cunado esto esa el BMU el server_id siempre va ser a nil, esto es por que la url esta fixeada en un archivo.
      # ServerConfiguration.find_by_server_id(args.first).site o algo parecido
      # CLOUD_URL + "/api/v1/#{args[0]}"
      host_resource(identity) + path_resource + controller_name + (object_id ? ('/' + object_id.to_s) : '') + (action_name ? ('/' + action_name) : '') + default_options(opts)
    end

    def host_resource(identity)
      # CLOUD_URL
      "http://0.0.0.0:3002"
    end

    def path_resource
      '/api/v1/'
    end

    def default_options(opts={})
       (opts.nil? || opts.empty?) ? '' : ('?' + opts.map{|key,value| "#{key}=#{value}" }.join("&"))
    end

    def token(identity)
      identity
    end
  end

  def site(*args)
    self.class.site(args)
  end
end
