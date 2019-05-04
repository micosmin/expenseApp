# Sketch behavior of API call
# Start with success path

require_relative '../../app/api.rb'

RSpec.describe API do
  describe 'POST /expenses' do
    context 'when the expense is sucessfully recorded' do
      it 'returns the expense id'
      it 'responds with a 200(OK'
    end
  end
end