class PlanMetricsController < ApplicationController
  def index
    @metrics = PlanMetric.filter(params[:market])

    respond_to do |format|
      format.json { render :json => @metrics.to_json }
    end
  end
end
