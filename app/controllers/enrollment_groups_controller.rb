class EnrollmentGroupsController < ApplicationController
  def index
    @q = params[:q]
    @qf = params[:qf]
    @qd = params[:qd]
	  # @enrollment_groups = EnrollmentGroup.search(@q, @qf, @qd).paginate(:page => params[:page], :per_page => 25)
    @enrollment_groups = EnrollmentGroup.search(@q, @qf, @qd).page(params[:page]).per(12) #.to_a.group_by { |p| p.name_last[0].upcase }

    respond_to do |format|
	    format.html # index.html.erb
	    format.json { render json: @enrollment_groups }
	  end
  end

  def show
	@enrollment_group = EnrollmentGroup.find(params[:id])
	@enrollments = @enrollment_group.enrollments

	  respond_to do |format|
		  format.html # index.html.erb
		  format.json { render json: @enrollment_group }
		end
  end
end
