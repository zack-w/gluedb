class EnrollmentTransmissionUpdatesController < ApplicationController

  def create
    @enrollment_transmission_update = EnrollmentTransmissionUpdate.new(params[:enrollment_transmission_update])
    @enrollment_transmission_update.save
    head :ok
  end

end
