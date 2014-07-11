class BrokersController < ApplicationController

  # The index page- should show a listing of brokers (paginated)
  def index
    # See if the user passed in a query argument (via HTTP GET)
    @q = params[:q];

    # Query based on the query argument if there is one
    @brokers = ( params[:q].present? && Broker.search(@q) || Broker ).page(params[:page]).per(12);

    # Support both HTML and Json responses
    respond_to do |format|
	    format.html # index.html.erb
	    format.json { render json: @brokers }
	  end
  end
  
  # Show details for a specific broker
  def show
    @brokerQuery = Broker.where( id: params[ :id ] );
    
    # If the broker being queried for doesn't exist, throw a 404
    if( 1 > @brokerQuery.count )then
      render( :file => "#{Rails.root}/public/404.html", :status => 404 );
      return;
    end

    # Setup then broker and employers variables for the view
    @broker = @brokerQuery.first;
		@employers = @broker.employers

    # Support both HTML and Json responses
	  respond_to do |format|
		  format.html # index.html.erb
		  format.json { render json: @broker }
		end
  end

end
