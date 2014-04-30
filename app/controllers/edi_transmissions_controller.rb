class EdiTransmissionsController < ApplicationController
  def index
	  # @edi_transmissions = EdiTransmission.all
	  @edi_transmissions = Protocols::X12::Transmission.limit(100)

    respond_to do |format|
	    format.html # index.html.erb
	    format.json { render json: @edi_transmissions }
	  end
  end

  def show
		@edi_transmission = Protocols::X12::Transmission.find(params[:id])

	  respond_to do |format|
		  format.html # index.html.erb
		  format.json { render json: @edi_transmission }
		end
  end
end
