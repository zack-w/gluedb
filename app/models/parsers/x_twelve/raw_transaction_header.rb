module Parsers
  module XTwelve
		class RawTransactionHeader
	    attr_reader :ts_id, :ts_control_number, :ts_implementation_convention_reference, :ts_date, :ts_time,
	    						:ts_time_zone_code, :ts_reference_id, :ts_action_code

	    extend EtfXpath

	    def initialize(doc)
        @ts_id = self.class.value_if_node(doc, "//etf:ST_TransactionSetHeader/etf:ST01__TransactionSetIdentifierCode")
        @ts_control_number = self.class.value_if_node(doc, "//etf:ST_TransactionSetHeader/etf:ST02__TransactionSetControlNumber")
        @ts_implementation_convention_reference = self.class.value_if_node(doc, "//etf:ST_TransactionSetHeader/etf:ST03__ImplementationConventionReference")

	    	@ts_purpose_code = self.class.value_if_node(doc, "//etf:BGN_BeginningSegment/etf:BGN01__TransactionSetPurposeCode")
        @ts_reference_number = self.class.value_if_node(doc, "//etf:BGN_BeginningSegment/etf:BGN02__TransactionSetReferenceNumber")
        @ts_date = self.class.value_if_node(doc, "//etf:BGN_BeginningSegment/etf:BGN03__TransactionSetCreationDate")
        @ts_time = self.class.value_if_node(doc, "//etf:BGN_BeginningSegment/etf:BGN04__TransactionSetCreationTime")
        @ts_time_zone_code = self.class.value_if_node(doc, "//etf:BGN_BeginningSegment/etf:BGN05__TimeZoneCode")
        @ts_reference_id = self.class.value_if_node(doc, "//etf:BGN_BeginningSegment/etf:BGN06__TransactionSetReferenceIdentifier")
        @ts_action_code = self.class.value_if_node(doc, "//etf:BGN_BeginningSegment/etf:BGN08__ActionCode")
	    end


      def to_model(ts_type)
	      trans = EdiTransactionSet.new(
          ts_id: @ts_id,
          ts_control_number: @ts_control_number,
          ts_implementation_convention_reference: @ts_implementation_convention_reference,
          ts_purpose_code: @ts_purpose_code,
          ts_reference_number: @ts_reference_number,
          ts_date: @ts_date,
          ts_time: @ts_time,
          ts_time_zone_code: @ts_time_zone_code,
          ts_reference_id: @ts_reference_id,
          ts_action_code: @ts_action_code,
          transaction_kind: ts_type
          )
      end
 

		end
	end
end