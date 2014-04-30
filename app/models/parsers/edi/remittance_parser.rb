require 'rubygems'
require 'bundler/setup'
require 'rsec'
require 'ostruct'

module Parsers
  module Edi
class RemittanceParser
  include Rsec::Helpers

  def seg(tag, max, f_def, s_term)
    seq(tag.r, f_def*(1..max), s_term)[1]
  end

  def parse(data)
  f_sep_char = data[3]
  seg_term_char = data[105]

  fc_regex = Regexp.compile("[^" + Regexp.quote(f_sep_char) + Regexp.quote(seg_term_char) + "]*")
  field_content = fc_regex.r

  f_sep = f_sep_char.r
  seg_term = seg_term_char.r

  field = seq(f_sep, field_content)[1]

  isa_seg = seg("ISA", 16, field, seg_term)
  iea_seg = seg("IEA", 2, field, seg_term)
  gs_seg = seg("GS", 8, field, seg_term)
  ge_seg = seg("GE", 2, field, seg_term)
  st_seg = seg("ST", 8, field, seg_term)
  se_seg = seg("SE", 2, field, seg_term)
  bpr_seg = seg("BPR", 21, field, seg_term)
  trn_seg = seg("TRN", 4, field, seg_term)
  ref_seg = seg("REF", 4, field, seg_term)
  n1_seg = seg("N1", 6, field, seg_term)
  per_seg = seg("PER", 9, field, seg_term)
  ent_seg = seg("ENT", 9, field, seg_term)
  nm1_seg = seg("NM1", 9, field, seg_term)
  rmr_seg = seg("RMR", 8, field, seg_term)
  dtm_seg = seg("DTM", 6, field, seg_term)

  l1000a = seq(n1_seg, ref_seg.maybe).map { |v| OpenStruct.new({ :N1 => v[0], :REF => v[1].first }) }
  l1000b = seq(n1_seg, per_seg.star).map { |v| OpenStruct.new({ :N1 => v[0], :PERs => v[1] }) }

  l2100 = seq(nm1_seg.maybe, ref_seg*(1..11)).map { |v| OpenStruct.new({ :NM1 => v[0].first, :REFs => v[1] }) }
  l2300 = seq(rmr_seg, ref_seg.star, dtm_seg).map { |v| OpenStruct.new({ :RMR => v[0], :REFs => v[1], :DTM => v[2]}) }

  l2000 = seq(ent_seg, l2100, l2300*(1..-1)).map { |v| OpenStruct.new({ :ENT => v[0], :L2100 => v[1], :L2300s => v[2]}) }

  l820 = seq(
    st_seg,
    bpr_seg,
    trn_seg,
    ref_seg*(0..4),
    l1000a,
    l1000b,
    l2000*(1..-1),
    se_seg).map do |v|
      OpenStruct.new({
        :ST => v[0],
        :BPR => v[1],
        :TRN => v[2],
        :REFS => v[3],
        :L1000A => v[4],
        :L1000B => v[5],
        :L2000s => v[6],
        :SE => v[7]
      })
    end

  interchange = seq(isa_seg, gs_seg, l820*(1..-1), ge_seg, iea_seg).map do |v|
    OpenStruct.new({
      :ISA => v[0],
      :GS => v[1],
      :L820s => v[2],
      :GE => v[3],
      :IEA => v[4]
    })
  end
    interchange.parse!(data)
  end
end
  end
end
