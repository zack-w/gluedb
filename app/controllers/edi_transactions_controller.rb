class EdiTransactionsController < ApplicationController
  def index
	  # @edi_transactions = EdiTransaction.all
	  @edi_transactions = EdiTransaction.limit(100)

    respond_to do |format|
	    format.html # index.html.erb
	    format.json { render json: @edi_transactions }
	  end
  end

  def show
		@edi_transaction = EdiTransaction.find(params[:id])

	  respond_to do |format|
		  format.html # index.html.erb
		  format.json { render json: @edi_transaction }
		end
  end
end
