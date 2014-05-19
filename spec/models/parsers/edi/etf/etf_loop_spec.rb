require 'spec_helper'

describe Parsers::Edi::Etf::EtfLoop do
  let(:etf) { Parsers::Edi::Etf::EtfLoop.new(raw_etf_loop) }

  describe '#subscriber_loop' do
    let(:not_subscriber) { { "INS" => ['','','']} }
    let(:subscriber) { { "INS" => ['','','18']} }
    let(:raw_etf_loop) { {"L2000s" => [ not_subscriber, subscriber]} }
    it 'returns subscriber person loop' do
      expect(etf.subscriber_loop).to eq subscriber
    end

    describe '#carrier_fein' do
      let(:carrier_fein) { '1234'}
      let(:raw_etf_loop) { {"L1000B" => { "N1" => ['','','','', carrier_fein]}} }

      it 'returns the carrier fein from the Payer loop' do
        expect(etf.carrier_fein).to eq carrier_fein
      end
    end
  end
end