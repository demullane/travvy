class HomeController < ApplicationController

  def map # doesn't work currently because of the change to pass the hotel location to the search model first
    @airbnb_results = AirbnbFetcher.new.airbnb_pretty_results
    @hotel_results = HotelFetcher.new.hotel_pretty_results(params[:location])

    results = []
    @airbnb_results.each do |listing|
      results << {:latitude => listing[:latitude], :longitude => listing[:longitude], :title => listing[:title], :image => listing[:image]}
    end
    @hotel_results.each_with_index do |listing, index|
      results << {:latitude => listing[:latitude], :longitude => listing[:longitude], :title => listing[:title], :image => listing[:image]}
    end
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

  def search
  end

end
