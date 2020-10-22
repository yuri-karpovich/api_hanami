# API app example
## Objectives
This is my test task. My goal was to create a concurrent? small and fast JSON API app.
- API calls should be faster than 100ms after data seeding (see [Data Seed](#data-seed))
- DB = PostgreSQL
- It's allowed to use any gems and ORMs
- Don't use RoR
- It's allowed to use DB capabilities to speed up responses
- Code should be clean, e.g. don't use generators
- Specs are required
 
### Endpoints
There are 3 models - `User` (fields: login), `Post` (fields: title, content, author ip address) and `Rating` (fields: value(1..5)). `Rating` belongs to `Post`, `Post` belongs to `User`.

#### Create Post
Params: title, content, author ip, author login

Behaviour: Create post. Create user if not exists

Response: 200 - created post attributes, 422 - in case of error  

> POST http://127.0.0.1:9292/api/v1/posts?login=<user>&title=<title>&ip=<ip>&content=<content>

#### Rate Post
Params: post id, rating

Behaviour: post has many ratings
> Important: action should work correctly on a concurrent update of the same post

Response: 200 - average post rating, 422 - in case of error

> PUT http://localhost:9292/api/v1/posts/<post_id>?rating=<rating>

 
#### Top Posts by Rating
Params: number of posts to return (optional)

Behaviour: Collection of posts with their attributes should be returned

Response: 200 - N posts with their attributes  

> GET http://localhost:9292/api/v1/posts?count=<count>

#### List of IP addresses 
Params: user logins

Behaviour: Get all user's IP addresses from his posts. It should be possible to get some users simultaneously

Response: 200 - users and their IP addresses

> GET http://localhost:9292/api/v1/users/ip?logins=<login1>%20<login2>

### Data Seed
`db/seed.db` file should be created. Import data to the DB using JSON API - start server and use API endpoints.

DB should be filled with:
- 100 uniq users
- 50 uniq IP addresses
- 200k posts
 
 
## Solution
This was my first non-Rails API app so I decided to create an app from scratch using something extremely light and fast. 
I should have used `Roda` or `Hanami` but my decision was to try something experimental :) 
So my choice for this test task is [`Hanami::API`](https://github.com/hanami/api). 

> Actually I've benchmarked requests/second for `Hanami::API`, `Hanami::Router` and `Roda`  on ruby 2.7.0 and the winner was `Hanami::Router`. `Roda` was very close to it. 
> Anyway I would prefer `Hanami` or `Roda` for production.

## Quick start
Install gems:
    
    bundle install
    
Start Postgres server:
    
    docker-compose up -d

Prepare database:
    
    bundle exec rake db:create RACK_ENV=production
    bundle exec rake db:migrate RACK_ENV=production
    
Start server:

    bundle exec bin/rackup -q -E production -o 127.0.0.1
    
Start data seed (~ 15 minutes):

    bundle exec rake db:seed RACK_ENV=production
    
## Run tests

    bundle exec rake db:create RACK_ENV=test
    bundle exec rake db:migrate RACK_ENV=test
    bundle exec rspec