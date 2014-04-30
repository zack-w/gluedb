class BrokersController < ApplicationController
  def index
	  @brokers = Broker.all.order_by([:name, :asc])

    respond_to do |format|
	    format.html # index.html.erb
	    format.json { render json: @brokers }
	  end
  end

  def show
		@broker = Broker.find(params[:id])
		@employers = @broker.employers

	  respond_to do |format|
		  format.html # index.html.erb
		  format.json { render json: @broker }
		end
  end
end
