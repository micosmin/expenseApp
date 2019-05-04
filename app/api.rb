require 'sinatra/base'
require 'json'

module ExpenseTracker
  class API < Sinatra::Base
    def initialize(storage: Storage.new) # pass in a storage object: dependency injection
      @storage = storage # child specific attr
      super() # call the initializer of the super class
    end

    post '/expenses' do
      expense = JSON.parse(request.body.read)
      result = @storage.record(expense) # save to DB
      JSON.generate('expense_id' => result.expense_id) # return this as a reponse to this request
    end

    get '/expenses/:date' do
      JSON.generate([]) # when hitting this route I get this back
    end
  end
end
