# Nube
**Nube** aims to be as flexible and abstract as possible while helping you work with remote object in different Rails applicaction as activerecord objects. It's 100% compatible with **Associations** (Locals-Remotes, Remote-Remote, Remote-local), **Scopes**, **Validations**. Besides is posible work with object from different Rails applications.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'nube'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install nube

## Usage
### Associations
Its possible define relations between differents class, locals with remotes. It's possible use any options, ***as***, ***dependent***, ***foreing_key***, , ***class_name***, etc.
For local class is only necessary:
1. Add ***include LocalAssociation***.
2. Define associations as activerecord but use ***remote_*** when you like define one relation with a remote class, for example: remote_belongs_to, remote_has_one, remote_has_many.

For Remote class is only necessary:
1. All remote class inherits from **Nube::Base**.
2. All relation definition is with ***remote_***

Examples:

#### Local class with Remote class or Remote class with Local class

```ruby
    # Rails app A with the persisting object
	Class Client < ActiveRecord::Base
      include LocalAssociation
      remote_has_one :remote_class, dependent: :nullify, foreign_key: "remote_class_foreign_key_id"
      remote_has_one :other_remote_class, through: :foo
      remote_has_many :foo_bar_remote_class, class_name: "RemoteClass", foreign_key: 'foo_bar_remote_class_id'
      belongs_to :remoteable, polymorphic: true
      belong_to :bar
    end

    # Rails app A with the persisting object
    class Bar < ActiveRecord::Base
      has_one :client
    end

    # Rails app B without the persisting object
    class Remote_class << Nube::Base
      remote_belongs_to :client
      remote_has_many :clients
      has_many :clients, as: :remoteable, class_name: "Client", dependent: :destroy
    end
```

#### Remote class with Remote class

```ruby
    # Rails app B without the persisting object
	Class Client < Nube::Base
      include LocalAssociation
      remote_has_one :remote_class, dependent: :nullify, foreign_key: "remote_class_foreign_key_id"
      remote_has_one :other_remote_class, through: :foo
      remote_has_many :foo_bar_remote_class, class_name: "RemoteClass", foreign_key: 'foo_bar_remote_class_id'
      remote_belongs_to :remoteable, polymorphic: true
    end

    # Rails app B without the persisting object
    class Remote_class < Nube::Base
      remote_remote_belongs_to :client
      remote_has_many :clients
      remote_has_many :clients, as: :remoteable, class_name: "Client", dependent: :destroy
    end
```
### Scopes

```ruby
    # Rails app A with the persisting object
    Class Client < ActiveRecord::Base # Rails app A
	  scope :submitted, -> { where(submitted: true) }
      scope :newer_than, -> (date1, date2) { where('start_date > ? and start_date < ?', date1, date2) }
      scope :late, -> { where("timesheet.submitted_at <= ?", 7.days.ago) }
    end

    # Rails app B without the persisting object
    class Client < Nube::Base
      scope :submitted # Only define the name
	  scope :newer_than, using: [:date1, :date2] # Onlye define scope name, and options.
	  scope :foo, remote_scope: :late  #Online define name. In this case the scope it's renamed
    end
```

### Validations

The validations must be defined where activerecord models exist. So when a class it's defined as Nube::Base, it's not necessary define any validations.

### API Controller

It's only necessary define:

```ruby
	class AnyController < ApplicationController
	  include NubeController
	  RESOURCE = ModelName
	end
```

The public action are:

1. index
2. count
3. create
4. update
5. update_all
6. destroy_all

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/nube. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
