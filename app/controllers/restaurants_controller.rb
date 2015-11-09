class RestaurantsController < ApplicationController
  def index
    if $error == "No Results"
      $error = "We couldn't find a restaurant matching that name, check the spelling and try again."
    end
  end



  def reviews
    @restaurant = params[:restaurant]
  end

  def show
    # @restaurant = Restaurant.find(params[:id])
  end

  def new
    $error = nil

    if params[:city]
      @city = params[:city]
      @response = Yelp.client.search( @city, { term: params[:restaurant], limit: 5 })
      if @response.total == 0
        $error = "No Results"
        redirect_to '/'
      end
    else
      redirect_to '/'
    end

  end

  def edit
    # @restaurant = Restaurant.find(params[:id])
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
