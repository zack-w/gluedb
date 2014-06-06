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
end
