class ToolsController < ApplicationController
  def premium_calc
    @carriers = Carrier.all.order_by([:name, :asc])
  end

end
