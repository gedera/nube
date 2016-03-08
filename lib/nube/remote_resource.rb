class RemoteResource
  include Site

  attr_reader :new_record
  attr_accessor :attributes, :attrs_changed, :errors

  alias_method :new_record?, :new_record

  def self.inherited(subclass)
    subclass.include(RemoteScope)
    subclass.include(RemoteAssociation)
  end

  def initialize attrs={}, new_record=true
    @new_record    = new_record
    @attrs_changed = {}
    @errors        = {}
    @attributes    = (attrs.empty? ? self.class.empty_attributes : attrs).stringify_keys
  end

  def save(params={})
    if new_record?
      remote_obj  = self.class.post(self.class.site({ controller: self.class.name.pluralize.underscore }, params.merge(identity)), { attributes: @attributes } ).first
      @attributes = remote_obj["object"]
      @errors     = remote_obj["errors"]
      @new_record = false if @errors.empty?
    else
      @errors = self.class.put(self.class.site({ controller: self.class.name.pluralize.underscore, id: id }, params.merge(identity)), { attributes: @attrs_changed } ).first
    end
    @errors.empty?
  end

  def update_attributes(attrs={})
    @attrs_changed.merge!(attrs)
    save
  end

  def update_attribute(attr, value)
    update_attributes(attr => value)
  end

  def destroy
    self.class.destroy_all(id: id).first unless id.nil?
  end

  ["get","post","put","delete"].each do |method|
    define_singleton_method method do |site, params={}|
      do_request(method, site, params)
    end
  end

  def identity
    _identity = nil
    _identity = if defined?(IDENTITY_ATTR)
                  send(IDENTITY_ATTR)
                elsif defined?(IDENTITY_SITE)
                  IDENTITY_SITE
                end
    _identity.nil? ? {} : { identity: _identity }
  end

  def inspect
    "#<#{self.class.name} " + attributes.keys.map{|attr| "#{attr}: #{attributes[attr].inspect}" }.join(', ') + '>'
  end

  # def model_name
  #   ActiveModel::Name.new self.class
  # end

  # def to_key
  #   [id] if id
  # end

  # def to_model
  #   self
  # end

  # def self.column_names
  #   new.attributes.keys
  # end

  # alias_method :persisted?, :new_record?

  def self.enum(options)
    options.each do |attr, values|
      values.each do |value|
        define_method "#{value}?" do
          self.send(attr) == value.to_s
        end
      end
    end
  end

  def self.do_request(method, site, params={})
    url = URI.parse(site)
    req = "Net::HTTP::#{method.to_s.camelize}".constantize.new(url.to_s)
    req.body = params.to_param
    res = Net::HTTP.start(url.host, url.port) {|http| http.request(req) }
    if (res.code == "200")
      [JSON.parse(res.body, quirks_mode: true)].flatten.compact
    else
      raise res.msg + res.code
    end
  end

  def method_missing(name, *args, &block)
    name = name.to_s
    setter = name.end_with?('=')
    name = name[0..-2] if setter
    if @attributes.has_key?(name)
      if setter
        @attributes[name] = args[0]
        @attrs_changed[name] = args[0]
      else
        @attributes[name]
      end
    else
      super
    end
  end

  def self.method_missing(name, *args, &block)
    super(name, *args) unless ("#{self.name}Relation".constantize.instance_methods - self.instance_methods).include?(name)
    args.empty? ? self.node.send(name) : self.node.send(name, args.first)
  end

end
