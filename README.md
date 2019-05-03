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
