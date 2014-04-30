class EnrollmentsController < ApplicationController
  def index
  end

  def show
    @enrollment = Enrollment.find(params[:id])
  end

  def canonical_vocabulary 
    @enrollment = Policy.find(params[:id])
    generated_filename = "#{@enrollment._id}.xml"
    send_data(@enrollment.to_cv, :type => "application/xml", :disposition => "attachment", :filename => generated_filename)
  end

    def new
    @enrollment = Enrollment.new
    @enrollment.enrollment_members.build

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @enrollment }
    end
  end

  def edit
    @enrollment = Enrollment.find(params[:id])
    @enrollment_members = @enrollment.enrollment_members
  end


  def update
    @enrollment = Enrollment.find(params[:id])

    respond_to do |format|
      if @enrollment.update_attributes(params[:enrollment])
        format.html { redirect_to @enrollment, notice: 'Enrollment was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @enrollment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @enrollment = Enrollment.find(params[:id])
    @enrollment.destroy

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end

end
