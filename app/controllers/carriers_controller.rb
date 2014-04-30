class CarriersController < ApplicationController
  def index
	  @carriers = Carrier.all.order_by([:name, :asc])

    respond_to do |format|
	    format.html # index.html.erb
	    format.json { render json: @carriers }
	  end
  end

  def show
		@carrier = Carrier.find(params[:id])
		@plans = @carrier.plans.ascending(:name, :hios_plan_id)

	  respond_to do |format|
		  format.html # index.html.erb
		  format.json { render json: @carrier }
		end
  end
end
