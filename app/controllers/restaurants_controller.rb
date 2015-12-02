require_relative '../services/reviews_finder'

class RestaurantsController < ApplicationController

  def index
    if $error
      $error_message = "We couldn't find a restaurant matching that name, check the spelling and try again."
    else
      $error_message = nil
    end
  end

  def reviews
    $error = nil
    city = "Toronto"
    yelp_response = Yelp.client.search( city, { term: params[:restaurant], category_filter: "restaurants,bars,cafes", limit: 5 })
    if yelp_response.total == 0
      $error = true
      redirect_to '/'
    else
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
    # @yelp_restaurant = Restaurant.find(params[:id])
  end

  def create
    # @restaurant = Restaurant.new(restaurant_params)

    # if @restaurant.save
    #   redirect_to restaurants_path
    # else
    #   render :new
    # end
  end

  def update
    # @restaurant = Restaurant.find(params[:id])

    # if @restaurant.update_attributes(restaurant_params)
    #   redirect_to restaurant_path(@restaurant)
    # else
    #   render :edit
    # end
  end

  def destroy
    # @restaurant = Restaurant.find(restaurant[:id])
    # @restaurant.destroy
    # redirect_to restaurants_path
  end

  protected

  def restaurant_params
    params.require(:restaurant).permit(
      :name, :address, :price_range, :cuisine, :city
      )
  end

end
