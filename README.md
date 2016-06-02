# HTML Fetcher

## Get it started
1. Clone this repo
2. `bundle install`
3.  a. `rake db:create`

    b. `rake db:migrate`
4. `brew install redis`

## Start server
1. `redis-server /usr/local/etc/redis.conf`
2. `bundle exec sidekiq`
3. `rails s`