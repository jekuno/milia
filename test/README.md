# Milia unit & functional testing

## Intro
Milia is tested using `minitest`.
Tests run in context of a multi-tenanted example application
(which resides in the `milia/test` directory).

## Running tests

The `test_helper.rb` takes care of maintaining the database
and loading the fixtures.

Run the tests as follows:

```
cd test
bundle install
RAILS_ENV=test bundle exec rake test
```  

## Fixtures vs Factories

For simplicity Milia uses static fixtures (instead of e.g. FactoryGirl)
as being the easiest way to have the test data fixtures.

## Structure of models under test

### Required by Milia/Devise

Universal (non-tenanted)
```
  User
    has_one: member
    habtm: tenants

  Tenant
    has_many: members
    habtm: users

  tenants_users HABTM join table
```

### Tenanted test models (added for typical app complexity)

The following models are <i>tenanted</i> which means
they all have an implicit `belongs_to: tenant`.

```
  Member
    belongs_to: user
    has_many :team_assets
    has_many :teams, :through => :team_assets, :source => 'team'
    has_many :posts
    has_many :zines, :through => :posts, :source => 'zine'

  Team
    has_many :team_assets
    has_many :team_members, :through => :team_assets, :source => 'member'
    has_many :posts, :through => :zines
    has_many :zines

  TeamAsset
    belongs_to :member
    belongs_to :team

  Post
    belongs_to  :member
    belongs_to  :zine
    has_one :team, :through => :zine

  Zine
    belongs_to  :team
    has_many    :posts
    has_many :members, :through => :posts, :source => 'member'
```

