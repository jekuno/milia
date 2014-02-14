# Milia unit testing

This documents the unit testing for Milia: structure of models, things
being tested, and work-arounds used. The reason for this document is
to aid future upgrade efforts.

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


