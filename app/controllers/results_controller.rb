class ResultsController < ApplicationController

  def listings
    if params[:location_input] && params[:arrival_date] && params[:departure_date] && params[:guest_count]

      us_valid, @location_data = Search.new.decipher_location_input_params(params[:location_input])
      if !us_valid
        flash[:alert] = @location_data
        redirect_to('/search')
      end

      @location_input = params[:location_input]
      @arrival_date = params[:arrival_date]
      @departure_date = params[:departure_date]
      @guest_count = params[:guest_count]
      @search_filter = params[:search_filter]

      if !(params[:search_filter] == 'Distance' || params[:search_filter] == 'Price')
        @search_filter = 'Distance'
      end

      hotel_valid, @hotel_results = HotelFetcher.new.hotel_pretty_results(@location_data, params[:arrival_date], params[:departure_date], params[:guest_count])
      if !hotel_valid
        @hotel_error_message = @hotel_results
      end

      airbnb_valid, @airbnb_results = AirbnbFetcher.new.airbnb_search_query(@location_data, params[:arrival_date], params[:departure_date], params[:guest_count])

      if hotel_valid
        @hotel_results = Filter.new.send(@search_filter.downcase.to_sym, @hotel_results)
      end
      if airbnb_valid
        @airbnb_results = Filter.new.send(@search_filter.downcase.to_sym, @airbnb_results)
      end
    end
  end

end
