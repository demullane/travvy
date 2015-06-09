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

      begin
        airbnb_valid, @airbnb_results = AirbnbFetcher.new.airbnb_search_query(@location_data, params[:arrival_date], params[:departure_date], params[:guest_count])
      rescue Mechanize::ResponseCodeError => e
        @airbnb_error_message = e
      end

      if hotel_valid
        @hotel_results = Filter.new.send(@search_filter.downcase.to_sym, @hotel_results)
      end

      if airbnb_valid
        @airbnb_results = Filter.new.send(@search_filter.downcase.to_sym, @airbnb_results)
      end

      results = @airbnb_results + @hotel_results

      @gmap_hash = Gmaps4rails.build_markers(results) do |listing, marker|
        # markers for airbnb listings
        if results.index(listing) < (@airbnb_results.size)
          marker.lat listing[:latitude]
          marker.lng listing[:longitude]
          marker.picture({
                    :url => "https://lh3.googleusercontent.com/-2VyHYkxy510/VTk_UpAq-wI/AAAAAAAAAd8/y5YiDJ2oykg/w28-h30-no/airbnb_marker_28x30.png",
                    :width   => 28,
                    :height  => 30  # must include height
                   })
        # markers for hotel listings
        else
          marker.lat listing[:latitude]
          marker.lng listing[:longitude]
          marker.picture({
                    :url => "https://lh3.googleusercontent.com/-gkXx-AkO1pU/VV5bfhkinxI/AAAAAAAAAfg/Qz9qbkokTM4/s31-no/hotel_marker_31x31.png",
                    :width   => 31,
                    :height  => 31  # must include height
                   })
        end
        marker.infowindow render_to_string(:partial => "/layouts/gmap", :locals => { :object => listing})
      end
    end
  end

end
