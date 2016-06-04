# HTML Fetcher

## Used technologies
- Ruby 2.2.4
- Ruby on Rails 4.2.6
- SQLite 3
- SASS, HAML, jQuery
- Sidekiq, Redis
- Nokogiri
- RSpec, FactoryGirl, Faker,...

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
4. visit `localhost:3000` for manual testing

## Main functionality
1.  The server **receives a URL from the front-end**.

    | request URL        | Behavior           |
    | ------------- |:-------------:|
    | URL is new     | create new PageResource and Job objects (status: creating) and push a new job into the Redis queue; send *job_id and page_id* back to the front-end |
    | URL is known and job is still in progress     | leave it alone |
    | URL is known and job was done recently (= today after midnight UTC)    | create new Job object (status: done) and send *job_id, page_id and html* to the front-end    |
    | URL is known and job is outdated (= yesterday before midnight UTC)    | create new Job object (status: updating), push a job to the Redis queue and send *job_id and page_id* to the front-end    |
    | URL is known and the job has failed, but the page can be reached now   | create new Job object (status: updating), push a job to the Redis queue and send *job_id and page_id* to the front-end    |
    | URL is known and the job has failed, but the page can not be reached   | leave it alone    |



2. The server **receives a request for a status update on the jobs:**

    it looks up the job and returns a status update - including the html if the job is done - to the front-end.

3. The Sidekiq worker handles the scraping of the desired pages in the background and sets the Job status to done.

## DB shema
####Jobs

| Column        | Datatype
| ------------- |:-------------:|
| id | integer|
| page_resource_id | integer|
| jid | sting|
| status | integer |
| created_at | datetime |
| updated_at | datetime |

####PageResources

| Column        | Datatype
| ------------- |:-------------:|
| id | integer|
| url | sting|
| html | text|
| statpopularityus | integer |
| created_at | datetime |
| updated_at | datetime |

## Testing
So far the app has 60 Rspec tests for the Controllers, Models, Helpers and the Worker.
To run them type in your console:

    rspec spec/

## Things to improve
1. The error handeling needs more work
2. The front-end could use some polish, but I build it mainly for trouble shooting
3. I'd like to spend more time on the Worker test cases
4. The view has at the moment no testing at all