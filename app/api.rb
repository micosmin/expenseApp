require 'sinatra/base'
require 'json'

module ExpenseTracker
  class API < Sinatra::Base
    post '/expenses' do
      JSON.generate('expense_id' => 42) # when hitting this route i get this back
    end

    get '/expenses/:date' do
      JSON.generate([]) # when hitting this route I get this back
    end
  end
end
