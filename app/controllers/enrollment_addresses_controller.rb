class EnrollmentAddressesController < ApplicationController

  def edit
    @enrollment_address = EnrollmentAddress.find(params[:id])
  end

  def update
    @enrollment_address = EnrollmentAddress.find(params[:id])

    respond_to do |format|
      if @enrollment_address.update_attributes(params[:enrollment_address])
        format.html { redirect_to person_path(Person.find(params[:id])), notice: 'Address was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
      end
    end
  end
end
