require 'spec_helper'

describe Parsers::Edi::TransmissionFile do
  let(:transmission_file) { Parsers::Edi::TransmissionFile.new(' ', ' ', ' ') }
  describe '#persist_broker_get_id' do
    context 'transmission has no broker loop' do
      let(:etf_loop) { {"L1000C" => Hash.new } }
      it 'returns nil' do
        expect(transmission_file.persist_broker_get_id(etf_loop)).to eq nil
      end
    end

    context 'transmission has broker loop' do
      let(:name) { 'SuperBroker' }
      let(:npn) { 'npn' }
      let(:etf_loop) { { 'L1000C' => { 'N1' => ['','', name, '', npn] } } }
      context 'npn absent' do
        let(:npn) { ' ' }
        it 'returns nil' do
          expect(transmission_file.persist_broker_get_id(etf_loop)).to eq nil
        end
      end

      context 'npn present' do
        it 'returns a broker id' do
          expect(transmission_file.persist_broker_get_id(etf_loop)).not_to eq nil
        end
      end
    end
  end

  describe '#subscriber_loop' do
    let(:not_subscriber) { { "INS" => ['','','']} }
    let(:subscriber) { { "INS" => ['','','18']} }
    let(:etf_loop) { {"L2000s" => [ not_subscriber, subscriber]} }
    it 'returns subscriber person loop' do
      expect(transmission_file.subscriber_loop(etf_loop)).to eq subscriber
    end
  end
end