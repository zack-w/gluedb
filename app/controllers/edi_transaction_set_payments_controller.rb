class EdiTransactionSetPaymentsController < ApplicationController

  def show
    @edi_transaction_set_payment = Protocols::X12::TransactionSetPremiumPayment.find(params[:id])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @edi_transaction_set }
    end
  end

end
