# Sketch behavior of API call
# Start with success path

require_relative '../../../app/api.rb'
require 'rack/test'

module ExpenseTracker
  RecordResult = Struct.new(:success?, :expense_id, :error_message) # status information packed up here for now
  RSpec.describe API do
    include Rack::Test::Methods # for testig HTTP requests to the API class

    def app
      API.new(storage: storage)
    end

    let(:storage) { instance_double('ExpenseTracker::Storage') }

    describe 'POST /expenses' do
      context 'when the expense is sucessfully recorded' do
        it 'returns the expense id' do
          expense = { 'some' => 'data' }

          allow(storage).to receive(:record).with(expense).and_return(RecordResult.new(true, 417, nil))
          post '/expenses', JSON.generate(expense)

          parsed = JSON.parse(last_response.body)
          expect(parsed).to include('expense_id' => 417)
        end

        it 'responds with a 200(OK'
      end

      context 'when the expense fails validation' do
        it 'returns an error message'
        it 'responds with a 422 (Unprocessable entity'
      end
    end
  end
end
