class PlansController < ApplicationController
  def index
    @q = params[:q]
    @qf = params[:qf]
    @qd = params[:qd]

    if params[:q].present?
      @plans = Plan.search(@q, @qf, @qd).page(params[:page]).per(15)
    else
      @plans = Plan.all.order_by(name_last: 1, name_first: 1).page(params[:page]).per(15)
    end
  end

  def show
    @plan = Plan.find(params[:id])
  end

  def calculate_premium
    plan = Plan.find(params[:id])
    rate_period_date = DateTime.strptime(params[:rate_period_date], '%m/%d/%Y')
    benefit_begin_date = DateTime.strptime(params[:benefit_begin_date], '%m/%d/%Y')
    birth_date = DateTime.strptime(params[:birth_date], '%m/%d/%Y')

    @rate = plan.rate(rate_period_date, benefit_begin_date, birth_date)
    
    respond_to do |format|
      format.js
    end

  end
end
