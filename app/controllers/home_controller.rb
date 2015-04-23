class HomeController < ApplicationController

  def index
    @results = AirbnbFetcher.new.pretty_results
  end

  def map
    @results = AirbnbFetcher.new.pretty_results
    @hash = Gmaps4rails.build_markers(@results) do |listing, marker|
      marker.lat listing[:latitude]
      marker.lng listing[:longitude]
      marker.infowindow listing[:title]
    end
  end

end
