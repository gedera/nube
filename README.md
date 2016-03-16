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
    Class Client < < ActiveRecord::Base
      include LocalAssociation
      remote_has_one :remote_class, dependent: :nullify, foreign_key: "remote_class_foreign_key_id"
      remote_has_one :other_remote_class, through: :foo
      remote_has_many :foo_bar_remote_class, class_name: "RemoteClass", foreign_key: 'foo_bar_remote_class_id'
      belongs_to :remoteable, polymorphic: true
      belong_to :bar
    end

    class Bar < ActiveRecord::Base
      has_one :client
    end

    class Remote_class << Nube::Base
      remote_belongs_to :client
      remote_has_many :clients
      has_many :clients, as: :remoteable, class_name: "Client", dependent: :destroy
    end
```

#### Remote class with Remote class

```ruby
    Class Client < < Nube::Base
      include LocalAssociation
      remote_has_one :remote_class, dependent: :nullify, foreign_key: "remote_class_foreign_key_id"
      remote_has_one :other_remote_class, through: :foo
      remote_has_many :foo_bar_remote_class, class_name: "RemoteClass", foreign_key: 'foo_bar_remote_class_id'
      remote_belongs_to :remoteable, polymorphic: true
    end

    class Remote_class << Nube::Base
      remote_remote_belongs_to :client
      remote_has_many :clients
      remote_has_many :clients, as: :remoteable, class_name: "Client", dependent: :destroy
    end
```
### Scopes

#### coming soon

### Validations

The validations must be defined where activerecord models exist. So when a class it's defined as Nube::Base, it's not necessary define any validations.

### API Controller

##### coming soon

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/nube. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
