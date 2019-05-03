require 'rack/test'
require 'json'

module ExpenseTracker
  RSpec.describe 'Expense Tracker API' do
    include Rack::Test::Methods

    it 'records submitted expense' do
      cofee = {
        'payee' => 'Pizza Union',
        'amount' => 10,
        'date' => '2019-4-16'
      }

      post '/expenses', JSON.generate(coffee)
    end
  end
end
