Behavior to test :

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

- sketch behavior for successful and unsucessful call to the POST / expense route

Step 10: Add behavior

- First, need a storage engine, which is called from the API to create a new instance when API is initialized.
- For testability and flexibility purposes I use dependency injection to pass a storage engine to the APP
- Dependency injection is as simple as passing an argument to a method
- This will allow us to create a double and mock behavior, thus removing dependency in tests and allowing me to test the API in isolation
- One disadvantage is that the caller always has to pass an object, but I can initialize the object when it is passed to have it there as a default, but also giving me the flexibility to pass a different object

Why do we need storage?

- when the POST request arrives with data, the API call will tell the storage to record the information from the POST request
- I have not tested storage yet, nor created the class, but I'm are not interested in it at the moment as I am implementing the desired behavior for the HTTP request, and will mock the storage

**Doubles**

- test double stands in for an object
- called mocks, stubs, fakes or spies - same thing
- to create a double for a particular instance of a class: instance_double with the name of the class i'm imitating
- define the double in let to use it across the test suite
- calling allow method from the RSpec_mocks
  - this method configures the test double's behavior
  - when caller (api invokes record, the double will return a new RecordResult instance)

Implement route code

- parse the expense sent to post
- use the storage to record the expense
- return JSON with expense_id

Implement test for 200 ok response

- Sinatra returns 200 HTTP unless an error occurs

Step 11:

- Test spec: expense request fails validation
  - mock the interface of the storage to send a fail response
  - this response is called by the api (storage is passed to the api as a mock)
  - this mocked response will be assigned to the result variable of the API post request
  - when it fails I'm expecting the message assigned to the api error_message

In the api:

- use an if else statement to test for success and failure
- raise a custom error code in sinatra: for example, use status 422 when it fails
- generate JSON with the hash expected in the test ('error' => result.error_message)

Step: 12 Define the storage class

- move RecordResult struct in this class / delete from api_spec
- require storage.rb in the test file api_spec

Tests fail at the moment as they are using the fake storage
Why do they not pass now that a storage class is defined?
Because of this: `the ExpenseTracker::Storage class does not implement the instance method: record`

- using instance_double forces us to only double real classes
- if a class is not implemented, it raises no errors
- once a class is implemented it will raise errors unless the specific class has the same behavior as the mocked one

This is an RSpec feature: called verifying double - instance_double

- test doubles mimic the interface of a real object.
- this ensures that specs keep track with the real object
- verifying doubles inspect the real object they are standing in for and fail the test if method signatures don't match

Conclusion: implement record method in storage.rb

Run tests: error message has changed to wrong number of arguments: Expected 0, got 1

- this means that RSpec sees the method, but the method is not taking an argument as the test does
- add expense argument to record method to fix this error

Step: 13 TDD get request

- double the storage class expenses_on method to return 2 expenses, or 3..dosen't matter
- this method will be called when the get route is hit
- in the test, parse the http response body JSON object
  - WHY? because the get request is set to generate a JSON object
- set an expectation to get the 2 expenses, or 3.. set when stubbing the method expenses_on

This won't work yet, as the storage class does not have the expenses_on method

- set the method, without implementing it

This will still not fully work, as the get route is not using the expenses_on method

- implement the use of the method, without worrying how the method actually works at the moment. We only need it there as a place holder so that we can use the double

Step 14: integrating the bottom layer = storage

- designing integration specs
- using SQlite db with Sequel gem

Create a configuration file which created db/test and db/production based on RACK_ENV
To create table use a Sequel migration
To apply migration tell Sequel to run it - configure RSpec to do this automatically when running integration tests

Step 15:

- TDD the record method of the storage class with a valid expense
- TDD the record method of the storage class with an invalid expense

Step 16: Restore system to clean slate after each spec
Isolate specs with Database transactions

- wrap each spec in a database transaction
- after each example - RSpec will roll back the transaction - cancelling any writes
- use RSpec `around` hook for this task

How does it work:

- you set it up in the db support file

```rb
  c.around(:example, :db) do |example|
    DB.transaction(rollback: :always) {example.run}
  end
```

- give it the :db tag. this will be used to signal that the example must be passed through this as it deals with the db
- to set up :db as a tag, I added the following to the spec helper

```ruby
config.when_first_matching_example_defined(:db) do
    require_relative 'support/db'
  end
```

- this tells RSpec to load the support/db when the :db tag is set

- RSpec calls the around hook passing it an example
- inside the hook, we start a new transaction which will roll back once it is done
- DB.transaction calls the inner block where RSpec will run
- once it is done, the DB will roll back all the changes
- around hook finishes and RSpec moves to the next example

To use this, we have to add the :db tag to the examples we want to pass through this hook, and explicitly load the setup code from support/db

As there might be several spec files touching the db, it's not good practice to add the support/db requiremenet in each of them.

Ask RSpec to add this for all examples that use the :db tag

```ruby
config.when_first_matching_example_defined(:db) do
    require_relative 'support/db'
  end
```

With the hook in place, RSpec will load the support/db.rb if any examples are loaded that have a:db tag

Next: add tag to specs
