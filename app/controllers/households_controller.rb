class HouseholdsController < ApplicationController
  def index
    @q = params[:q]
    @qf = params[:qf]
    @qd = params[:qd]

    if params[:q].present?
      @households = Household.search(@q, @qf, @qd).page(params[:page]).per(15)
    else
      @households = Household.page(params[:page]).per(15)
    end


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

  def new
    @household = Household.new
    build_nested_models

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @household }
    end
  end

  def create
    @household = Household.new(params[:household])

    respond_to do |format|
      if @household.save
        format.html { redirect_to @household, notice: 'Household was successfully created.' }
        format.json { render json: @household, status: :created, location: @household }
      else
        format.html { render action: "new" }
        format.json { render json: @household.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @household = Household.find(params[:id])
    build_nested_models
  end

  def update
    @household = Household.find(params[:id])

    respond_to do |format|
      if @household.update_attributes(params[:household])
        format.html { redirect_to @household, notice: 'Household was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @household.errors, status: :unprocessable_entity }
      end
    end
  end

private
  def build_nested_models
    @household.people.build if @household.people.empty?
    @household.special_enrollment_periods.build if @household.special_enrollment_periods.empty?
    @household.eligibilities.build if @household.eligibilities.empty?
  end


end
