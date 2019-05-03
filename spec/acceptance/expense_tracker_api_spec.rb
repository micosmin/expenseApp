require 'rack/test'
require 'json'
require_relative '../../app/api.rb'

module ExpenseTracker
  RSpec.describe 'Expense Tracker API' do
    include Rack::Test::Methods

    def app
      ExpenseTracker::API.new
    end

    def post_expense(expense)
      post '/expenses', JSON.generate(expense)
      expect(last_response.status).to eq(200)

      parsed = JSON.parse(last_response.body)
      expect(parsed).to include('expense_id' => a_kind_of(Integer))
    end

    it 'records submitted expense' do
      coffee = {
        'payee' => 'Pizza Union',
        'amount' => 10,
        'date' => '2019-4-16'
      }
      post_expense(coffee)
    end
  end
end
