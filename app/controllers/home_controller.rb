class HomeController < ApplicationController

  def index
    @results = AirbnbFetcher.new.pretty_results
  end

  def map

  end

end
