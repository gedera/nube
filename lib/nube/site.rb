module Site

  extend ActiveSupport::Concern

  class_methods do
    def site(*args)
      # Cunado esto esa el BMU el server_id siempre va ser a nil, esto es por que la url esta fixeada en un archivo.
      # ServerConfiguration.find_by_server_id(args.first).site o algo parecido
      # CLOUD_URL + "/api/v1/#{args[0]}"
      host_resource(args) + path_resource + args[0].values.join('/') + default_options(args[1])
    end

    def host_resource(*args)
      # CLOUD_URL
      "http://0.0.0.0:3002"
    end

    def path_resource
      '/api/v1/'
    end

    def default_options(opts={})
       (opts.nil? || opts.empty?) ? '' : ('?' + opts.map{|key,value| "#{key}=#{value}" }.join("&"))
    end
  end

  def site(*args)
    self.class.site(args)
  end
end
