class HouseholdsController < ApplicationController
  def index
	  @households = Household.all

    respond_to do |format|
	    format.html # index.html.erb
	    format.json { render json: @households }
	  end
  end

  def show
		@household = Household.find(params[:id])

	  respond_to do |format|
		  format.html # index.html.erb
		  format.json { render json: @household }
		end
  end
end
