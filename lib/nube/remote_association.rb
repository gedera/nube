module RemoteAssociation

  extend ActiveSupport::Concern
  include RemoteRelation

  class_methods do

    def belongs_to(rel, opts={})
      remote_belongs_to(rel, opts)
    end

    def has_one(rel, opts={})
      remote_has_one(rel, opts)
    end

    def has_many(rel, opts={})
      remote_has_many(rel, opts)
    end

    def reflection(rel=nil)
      rel.nil? ? remote_reflections : remote_reflections.select{|r| r[:rel] == rel }.first
    end
  end
end
