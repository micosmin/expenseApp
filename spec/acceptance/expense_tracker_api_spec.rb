require 'rack/test'
require 'json'
require_relative '../../app/api.rb'

module ExpenseTracker
  RSpec.describe 'Expense Tracker API' do
    include Rack::Test::Methods

    def app
      ExpenseTracker::API.new
    end

    it 'records submitted expense' do
      coffee = {
        'payee' => 'Pizza Union',
        'amount' => 10,
        'date' => '2019-4-16'
      }

      post '/expenses', JSON.generate(coffee)
      expect(last_response.status).to eq(200)
    end
  end
end
