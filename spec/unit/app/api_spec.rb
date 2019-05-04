# Sketch behavior of API call
# Start with success path

require_relative '../../../app/api.rb'
require_relative '../../../app/storage.rb'
require 'rack/test'

module ExpenseTracker
  RSpec.describe API do
    include Rack::Test::Methods # for testig HTTP requests to the API class

    def app
      API.new(storage: storage)
    end

    let(:storage) { instance_double('ExpenseTracker::Storage') }
    let(:expense) { { 'some' => 'data' } }

    before do
      allow(storage).to receive(:record).with(expense).and_return(RecordResult.new(true, 417, nil))
    end

    describe 'POST /expenses' do
      context 'when the expense is sucessfully recorded' do
        it 'returns the expense id' do
          post '/expenses', JSON.generate(expense)

          parsed = JSON.parse(last_response.body)

          expect(parsed).to include('expense_id' => 417)
        end

        it 'responds with a 200(OK)' do
          post '/expenses', JSON.generate(expense)

          expect(last_response.status).to eq(200)
        end
      end

      context 'when the expense fails validation' do
        let(:expense) { { 'some' => 'data' } }

        before do
          # this mocked interface sets the response to the API call which is tested below
          allow(storage).to receive(:record).with(expense).and_return(RecordResult.new(false, 415, 'Expense incomplete'))
        end

        it 'returns an error message' do
          post '/expenses', JSON.generate(expense) # sends a post request with the expense JSON to API
          parsed = JSON.parse(last_response.body) # this converts the response from the API into a hash
          expect(parsed).to include('error' => 'Expense incomplete') # expectation check if this is in the response from the API
        end

        it 'responds with a 422 (Unprocessable entity)' do
          post '/expenses', JSON.generate(expense)
          expect(last_response.status).to eq(422) # status response comes from the API - status 422 set in the response coming from the API - raising a custom error code
        end
      end
    end
  end
end
