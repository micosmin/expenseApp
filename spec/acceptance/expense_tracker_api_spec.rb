require 'rack/test'
require 'json'
require_relative '../../app/api.rb'

module ExpenseTracker
  RSpec.describe 'Expense Tracker API', :db do
    include Rack::Test::Methods

    def app
      ExpenseTracker::API.new
    end

    def post_expense(expense)
      post '/expenses', JSON.generate(expense)
      expect(last_response.status).to eq(200)
      parsed = JSON.parse(last_response.body)
      expect(parsed).to include('expense_id' => a_kind_of(Integer))
      expense.merge('id' => parsed['expense_id'])
    end

    it 'records submitted expense' do
      coffee = post_expense(
        'payee' => 'Pizza Union',
        'amount' => 10.0,
        'date' => '2019-04-16'
      )
      zoo = post_expense(
        'payee' => 'Just pizza',
        'amount' => 10.0,
        'date' => '2019-04-15'
      )

      get '/expenses/2019-04-15'
      expect(last_response.status).to eq(200)

      expenses = JSON.parse(last_response.body)
      expect(expenses).to contain_exactly(zoo)
    end
  end
end
