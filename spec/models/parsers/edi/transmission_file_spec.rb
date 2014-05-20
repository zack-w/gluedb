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

  describe '#cancellation_or_termination?' do
    context 'given no member level detail(INS)' do
      let(:etf_loop) { {'L2000s' => [ { "INS" => [] } ]}} #'', '', '', ''
      it 'returns false' do 
        expect(transmission_file.cancellation_or_termination?(etf_loop)).to eq false
      end
    end

    context 'given member level detail stating cancellation or termination' do
      let(:etf_loop) { {'L2000s' => [ { "INS" => ['', '', '', '024'] } ]}}
      it 'returns true' do 
        expect(transmission_file.cancellation_or_termination?(etf_loop)).to eq true
      end
    end

    context 'given some other maintainance type code' do
      let(:etf_loop) { {'L2000s' => [ { "INS" => ['', '', '', '666'] } ]}}
      it 'returns false' do 
        expect(transmission_file.cancellation_or_termination?(etf_loop)).to eq false
      end
    end
  end

  describe '#determine_transaction_set_kind' do
    context 'effectuation that contains a cancellation or term' do
      let(:etf_loop) { {'L2000s' => [ { "INS" => ['', '', '', '024'] } ]}}
      before { transmission_file.transmission_kind = 'effectuation' }
      its 'a maintainace' do 
        expect(transmission_file.determine_transaction_set_kind(etf_loop)).to eq 'maintenance'
      end
    end
  end
end