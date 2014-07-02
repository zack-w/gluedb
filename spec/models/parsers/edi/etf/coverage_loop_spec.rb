require 'spec_helper'

describe Parsers::Edi::Etf::CoverageLoop do
  let(:coverage_loop) { Parsers::Edi::Etf::CoverageLoop.new(raw_loop)}
  describe '#eg_id' do
    let(:eg_id) { '1234' }
    let(:raw_loop) { { "REFs" => [['', '1L', eg_id]] } }
    it 'exposes the eg_id from the health coverage loop (2300)' do
      expect(coverage_loop.eg_id).to eq eg_id
    end
  end

  describe '#hios_id' do
    let(:hios_id) { '1234' }
    let(:raw_loop) { { "REFs" => [['', 'CE', hios_id]] } }
    it 'exposes the hios_id from the health coverage loop (2300)' do
      expect(coverage_loop.hios_id).to eq hios_id
    end
  end
end