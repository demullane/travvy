class HomeController < ApplicationController

  def index
    @airbnb_results = AirbnbFetcher.new.airbnb_pretty_results
  end

  def map
    @airbnb_results = AirbnbFetcher.new.airbnb_pretty_results
    @gmap_hash = Gmaps4rails.build_markers(@airbnb_results) do |listing, marker|
      marker.lat listing[:latitude]
      marker.lng listing[:longitude]
      marker.picture({
                :url => "https://lh3.googleusercontent.com/-2VyHYkxy510/VTk_UpAq-wI/AAAAAAAAAd8/y5YiDJ2oykg/w28-h30-no/airbnb_marker_28x30.png",
                :width   => 28,
                :height  => 30  # must include height
               })
      marker.infowindow render_to_string(:partial => "/layouts/gmap", :locals => { :object => listing})
    end
  end

  def hotels
    @hotel_results = HotelFetcher.new.hotel_pretty_results
  end

end
