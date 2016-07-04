module NubeController
  extend ActiveSupport::Concern

  def resource
    defined?(self.class::RESOURCE) ? self.class::RESOURCE : controller_name.singularize.camelize.constantize
  end

  def index
    render json: apply_scopes
  end

  def count; render json: apply_scopes.count; end

  def create
    obj = resource.create(attributes)
    render json: { object: obj.attributes, errors: obj.errors.messages }
  end

  def update
    obj = resource.find(params[:id])
    obj.update_attributes(attributes)
    render json: obj.errors.messages
  end

  def update_all; render json: apply_scopes.update_all(params[:changes]); end

  def destroy_all; render json: apply_scopes.destroy_all; end

  def massive_sum; resource.massive_sum(transaction); end

  def massive_update; resource.massive_update(transaction); end

  def massive_creation; resource.massive_creation(transaction); end

  def empty_attributes; render json: resource.new ; end

  private

  def self.resource(xmodel); @@resource = xmodel; end

  def apply_relations; @resource = @resource.where(relations).where(server_id: params[:server_id]); end

  def parse_request; @json = JSON.parse(request.body.read); end

  def apply_joins; @resource = @resource.joins(joins); end

  def apply_scope; scopes.each { |key, value| @resource = value.is_a?(Hash) ? @resource.send(key, *value.values) : @resource.send(key) }; end

  def apply_limit; @resource = @resource.limit(limit); end

  def apply_offset; @resource = @resource.offset(offset); end

  def apply_where; where.each { |condition| @resource = @resource.where(condition) }; end

  def apply_order; order.each { |condition| @resource = @resource.order(condition) }; end

  def apply_search; @resource = @resource.search(search).result; end

  def transaction; params.has_key?(:transaction) ? (params.require(:transaction).is_a?(Hash) ? params.require(:transaction).permit! : params[:transaction]) : {}; end

  def attributes; params.has_key?(:attributes) ? params.require(:attributes).permit!: {}; end

  def relations; params.has_key?(:relations) ? params.require(:relations).permit! : {}; end

  def scopes; params.has_key?(:scopes) ? params.require(:scopes).permit! : {}; end

  def joins; params.has_key?(:joins) ? params.require(:joins).map(&:to_sym): []; end

  def where; params.has_key?(:where) ? params.require(:where).map{|con| con.is_a?(Hash) ? con.permit! : con } : []; end

  def order; params.has_key?(:order) ? params.require(:order).map{|con| con.is_a?(Hash) ? con.permit! : con } : []; end

  def limit; params.has_key?(:limit) ? params[:limit].to_i : nil; end

  def offset; params.has_key?(:offset) ? params[:offset].to_i : nil; end

  def search; params.has_key?(:search) ? params.require(:search).permit! : {}; end

  def apply_scopes
    @resource = resource
    apply_search
    apply_relations
    apply_joins
    apply_scope
    apply_where
    apply_order
    apply_limit
    apply_offset
  end

end
#end
