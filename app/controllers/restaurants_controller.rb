require_relative '../services/reviews_finder'

class RestaurantsController < ApplicationController

  def index
    if $error
      $error_message = "We couldn't find a restaurant matching that name, check the spelling and try again."
    else
      $error_message = nil
    end
    $error = nil
  end

  def reviews
    $error = nil

    # Limit search to Toronto
    city = "Toronto"

    # Use Yelp API to check if restaurant exists
    yelp_response = Yelp.client.search( city, { term: params[:restaurant], category_filter: "restaurants,bars,cafes", limit: 5 })

    if yelp_response.total == 0
      $error = true
      redirect_to '/'
    else
      # Use service to scrape data
      @data = ReviewsFinder.find_reviews(yelp_response)
    end

  end

  def contact
  end

  def show

  end

  def new

  end

  def edit

  end

  def create

  end

  def update
]
  end

  def destroy

  end

  protected

  def restaurant_params
    params.require(:restaurant).permit(
      :name, :address, :price_range, :cuisine, :city
      )
  end

end
