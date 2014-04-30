class EdiTransactionSetsController < ApplicationController
  def index
	  # @edi_transaction_sets = EdiTransactionSet.all
	  @edi_transaction_sets = Protocols::X12::TransactionSetEnrollment.limit(100)

    respond_to do |format|
	    format.html # index.html.erb
	    format.json { render json: @edi_transaction_sets }
	  end
  end

  def show
		@edi_transaction_set = Protocols::X12::TransactionSetEnrollment.find(params[:id])

	  respond_to do |format|
		  format.html # index.html.erb
		  format.json { render json: @edi_transaction_set }
		end
  end
end
