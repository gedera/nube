require 'rails'
require 'action_controller'
require 'active_support'
require 'action_pack'
require 'active_model'
require 'nube/version'
#require 'nube/controllers/base_api_controller.rb'

module Nube
  extend ActiveSupport::Autoload

  autoload :Base
  autoload :Site
  autoload :RemoteRelation
  autoload :RemoteScope
  autoload :LocalAssociation
  autoload :RemoteAssociation
  autoload :BaseApiController, 'nube/controllers/base_api_controller'
end
