Behavior to test:

1. API saves the expense we record

Objective:
Test the API behavior

- I can nest modules inside a describe block: nesting Rack::Test::Methods
- Using this particular module for the 'post' helper method
  - This simulated an HTTP POST request
  - It calls the app directly, and does not generate or parse HTTP Packets

First test

- created a hash - because JSON objects convert ot ruby hashes
- passing the hash to JSON generator to post it via the post method
- test fails as there is no APP - this comes from the Rake::Test module post helper method. This error tells us that we need an app method that returns an object representing our web app

Documentation:

This module serves as the primary integration point for using Rack::Test in a testing environment. It depends on an app method being defined in the same context, and provides the Rack::Test API methods (see Rack::Test::Session for their documentation).

Example:

```ruby
class HomepageTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    MyApp.new
  end
end
```

Hard-coding test end to end - sliming the test. Will come back to implement behavior properly

Step 1: Pass the test with the simplest implementation possibile

- Create an app method inside the describe block. This is needed by Rack::Test
- This changes the error to: NameError: uninitialized constant ExpenseTracker::API
- For this we need to create the ExpenseTracker module with an API class
  - we do this in a separate file called api nested in an app folder

Step 2: Checking response to http post request

- Rack::test - has a last_response method for checking HTTP responses: expect(last_response.status).to eq(200)
- This will return an error at the moment as we have not added any routes to our application
  - for this we add a post route for '/expense' path to the API class in Expense tracker.

I am still keeping this to the level of the simplest code needed to pass the tests

Step 3: Create a response body

- for each expense, get back a uniq id
- in this example I am passing one matcher into another, so that i can express in general terms what I am expecting out of this test
- using include and a_kind_of

```ruby
parsed = JSON.parse(last_response.body)
expect(parsed).to include('expense_id' => a_kind_of(Integer))
```

- this will error as the response sent back is empty at the moment: JSON::ParseError: 743: unexpected token at ''

To generate the response, in the post route i need to generate a json

Git: [master afcf746] Test: json response in body

Step 4: Move generating a post to a helper method
Step 5: TDD a get request

- Sent to post requests
- Created an expectation for a response (200) when a get route is reached
- I want the date to be the id based on which the item is retrieved

Test will fail initially as the get route has not been created yet
Once route is created, I'll write some code to save/retrieve the data

```ruby
get '/expenses/:date' do
  JSON.generate([])
end
```

- Before implementing code - save work
- Add pending 'some string' in the test under consideration

Step 6: Set up rackup config file to run a server locally
Step 7: Run server locally and curl into the get request /expenses/:date

- we will receive an empty JSON array back, which was generated in the get path

Step 8: Uniy testing in isolation the HTTP layer

- simulating HTTP requests through Rack::Test interface = not calling methods on the API class directly
- testing a class through it public interface
- HTTP interface is the public interface
- Will isolate public-facing API from the underlying storage engine
- testing one layer of the app at a time
  - drive behavior of API class that routes requests to the storage engine (DB)

Will be using different RSpec testings than up to now

- random order RSpec
- verbose documentation
- testing without changes to Ruby core classes

These suggestions are in spec_helper - commented out

Added to RSpec.configure: `config.filter_gems_from_backtrace 'rack', 'rack-test', 'sequel', 'sinatra'` because I want to filter out the backtrace framework code from these gems

To see the full backtrack i can add --backtrace or -b flag to RSpec when running the test

Step 9: Sketch behavior:

- break it down into broad categories

`Want to see what happens when an API call succeeds or fails`

- I'm using unit tests also to test Edge cases

Start with sketching out the success case in the api_spec.rb file (new file)

Create a unit/app folder
