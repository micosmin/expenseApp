require_relative '../../../app/storage'
require_relative '../../../config/sequel'

module ExpenseTracker
  RSpec.describe Storage, :aggregate_failures, :db do
    # There are the same for each example
    let(:storage) { Storage.new }
    let(:expense) do
      {
        'payee' => 'Starbucks',
        'amount' => 5.75,
        'date' => '2019-04-28'
      }
    end

    describe '#record' do
      context 'with a valid expense' do
        it 'sucessfull saves the expense to the db' do
          result = storage.record(expense)
          expect(result).to be_success
          expect(DB[:expenses].all).to include(
            id: result.expense_id,
            payee: 'Starbucks',
            amount: 5.75,
            date: Date.iso8601('2019-04-28')
          )
        end
      end

      context 'when the expense lacks a payee' do
        it 'rejects the expense as invalid' do
          expense.delete('payee')
          result = storage.record(expense)
          expect(result).not_to be_success
          expect(result.expense_id).to eq(nil)
          expect(result.error_message).to include('payee is required')
          expect(DB[:expenses].count).to eq(0)
        end
      end
    end
  end
end
