class ToolsController < ApplicationController
  def premium_calc
    @carriers = Carrier.all
    @plans = Plan.all
  end

end
