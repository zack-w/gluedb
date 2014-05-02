require 'spec_helper'

describe DeletionDeltaExtractor do
  context 'nothing was deleted' do
    it 'returns empty hash' do
      input = { "phones_attributes"=> {"0"=> { :phone_number=>"222-222-2222", :id =>"0", :_destroy=>"false"}}}
      extractor = DeletionDeltaExtractor.new(input)
      expect(extractor.extract).to eq Hash.new
    end
  end

  context 'nested attribute is deleted' do
    it 'returns a hash containing the deltas' do
      input = { "phones_attributes"=> {"0"=> { :phone_number=>"222-222-2222", :id=>"1", :_destroy=>"1"}}}
      puts input 
      extractor = DeletionDeltaExtractor.new(input)
      puts extractor.extract

      delta = Hash.new
      delta[:phone_number] = Hash.new
      delta[:phone_number][:from] = "222-222-2222"
      delta[:phone_number][:to] = nil
      delta[:_id] = Hash.new
      delta[:_id][:from] = '1'
      delta[:_id][:to] = nil

      output = Hash.new
      output[:phones] = []
      output[:phones] << delta
      expect(extractor.extract).to eq output
    end
  end
end