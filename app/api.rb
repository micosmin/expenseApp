require 'sinatra/base'
require_relative './storage'
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
      # success and error_message are created through the mock in the first iteration of thets
      if result.success?
        JSON.generate('expense_id' => result.expense_id) # return this as a reponse to this request
      else
        status 422
        JSON.generate('error' => result.error_message)
      end
    end

    get '/expenses/:date' do
      JSON.generate(@storage.expenses_on(params[:date])) # when hitting this route I get this back
    end
  end
end
