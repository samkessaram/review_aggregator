class WelcomeController < ApplicationController

  def index
    @cities = HTTParty.get('http://opentable.herokuapp.com/api/cities')["cities"]
  end

end