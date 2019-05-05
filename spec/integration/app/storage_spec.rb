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

    describe '#expenses_on' do
      it 'returns all expenses for the provided date' do
        result_1 = storage.record(expense.merge('date' => '2019-03-10'))
        result_2 = storage.record(expense.merge('date' => '2019-03-10'))
        result_3 = storage.record(expense.merge('date' => '2019-03-11'))

        expect(storage.expenses_on('2019-03-10')).to contain_exactly(
          a_hash_including(id: result_1.expense_id),
          a_hash_including(id: result_2.expense_id)
        )
      end

      it 'returns a blank array when tehre are no matching expenses' do
        expect(storage.expenses_on('2019-03-10')).to eq([])
      end
    end
  end
end
