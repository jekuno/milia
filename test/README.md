# Milia unit & functional testing

This documents the unit testing for Milia: structure of models, things
being tested, and work-arounds used. The reason for this document is
to aid future upgrade efforts.

## fixture vs factories?

Milia v0.3 used factory_girl to generate test fixtures, but there
were difficulties dealing with both the dynamic nature of creating
objects which had to have an existing current_tenant established. In
between v0.3 and v1.0, factory_girl upgraded significantly and meant
all the test code would have to be reworked.

Rather than relearning FactoryGirl and the extensive changes to
make it work, I've decided to just use static fixtures as being
the easiest way to have the test data fixtures.

## Model structure

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

### models added for typical app complexity

Tenanted
<i>Means they all have an implicit: belongs_to: tenant</i>

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

## running tests

You must cd into the milia/test directory.
Then run test:units, test:functionals seperately. 

```ruby
  $ cd test
  $ rake db:create
  $ rake db:migrate
  $ rake db:test:prepare
  $ rake test:units
  $ rake test:functionals
```

