class ToolsController < ApplicationController
  def premium_calc
    @carriers = Carrier.all
  end

end
