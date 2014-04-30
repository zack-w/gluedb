require 'csv'

namespace :edi do
  namespace :import do
    def with_progress_bar(file, message)
      fs = File.size(file)
      f = File.open(file)
      pb = ProgressBar.create(
        :title => "Loading #{message}",
        :total => fs,
        :format => "%t %a %e |%B| %P%%"
      )
      CSV.foreach(f, :headers => true) do |data|
        yield data
        pb.progress += data.to_s.length
      end
      pb.finish
    end

    desc "Import outbound 820s from the exported EDI"
    task :outbound_820 => :environment do
      f = File.join(Rails.root, "db", "data", "b2b_outbound_820.csv")
      with_progress_bar(f, "820s") do |row|
        record = row.to_hash
        f_name = record['PROTOCOLMESSAGEID']
        p = Parsers::Edi::RemittanceTransmission.new(f_name, record['WIREPAYLOADUNPACKED'])
        p.persist!
      end
    end

    desc "Import it all from the JSONs"
    task :all => :environment do
      f = File.join(Rails.root, "db", "data", "all_json.csv")
      with_progress_bar(f, "ie 834s") do |row|
        record = row.to_hash
        f_name = record['PROTOCOLMESSAGEID']
        trans_kind = record['TRANSTYPE']
        case trans_kind
        when "999"
          p = Parsers::Edi::TransactionSetResult.new(f_name, record['WIREPAYLOADUNPACKED'])
          p.persist!
        when "TA1"
          p = Parsers::Edi::TransmissionResponse.new(f_name, record['WIREPAYLOADUNPACKED'])
          p.persist!
        when "820"
          p = Parsers::Edi::RemittanceTransmission.new(f_name, record['WIREPAYLOADUNPACKED'])
          p.persist!
        else
          p = Parsers::Edi::TransmissionFile.new(f_name, trans_kind, record['WIREPAYLOADUNPACKED'])
         p.persist!
        end
      end
    end
  end
end
