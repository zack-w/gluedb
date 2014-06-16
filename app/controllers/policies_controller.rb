class PoliciesController < ApplicationController
  def show
    @policy = Policy.find(params[:id])
    respond_to do |format|
      format.xml
    end
  end
end
