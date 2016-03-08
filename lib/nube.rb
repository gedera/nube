require 'nube/version'
require 'nube/site'
require 'nube/remote_relation'
require 'nube/remote_scope'
require 'nube/local_association'
require 'nube/remote_association'
require 'nube/controllers/nube_controller'

module Nube
  extend ActiveSupport::Autoload

  autoload :Base
  autoload :Site
  autoload :RemoteRelation
  autoload :RemoteScope
  autoload :LocalAssociation
  autoload :RemoteAssociation
  autoload :NubeController
end
