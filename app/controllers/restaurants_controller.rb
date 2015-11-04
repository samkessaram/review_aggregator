class RestaurantsController < ApplicationController
  def index
    @city = params[:city]

    if @city.include? ' '
      @city.gsub!(' ','+')
    end

    page_1 = HTTParty.get('http://opentable.herokuapp.com/api/restaurants?city=' + @city + '&per_page=100')
    num_pages = ( page_1["total_entries"] / 100 ) + ( (page_1["total_entries"] % 100) / (page_1["total_entries"] % 100) )
    # binding.pry
    @restaurants = []
    count = 1

    until count > num_pages
      page = HTTParty.get('http://opentable.herokuapp.com/api/restaurants?city=' + @city + '&page=' + count.to_s + '&per_page=100')
      page["restaurants"].each do |restaurant|
        restaurant = Restaurant.new(name:restaurant["name"], address:restaurant["address"], price_range:restaurant["price"], city:restaurant["city"])
        @restaurants << restaurant
      end
      count += 1
    end
    @restaurants.sort!{|a,b| a.name <=> b.name }

    @restaurants = Kaminari.paginate_array(@restaurants).page(params[:page]).per(25)

  end

  def show
    @restaurant = Restaurant.find(params[:id])
  end

  def new
    @restaurant = Restaurant.new
  end

  def edit
    @restaurant = Restaurant.find(params[:id])
  end

  def create
    @restaurant = Restaurant.new(restaurant_params)

    if @restaurant.save
      redirect_to restaurants_path
    else
      render :new
    end
  end

  def update
    @restaurant = Restaurant.find(params[:id])

    if @restaurant.update_attributes(restaurant_params)
      redirect_to restaurant_path(@restaurant)
    else
      render :edit
    end
  end

  def destroy
    @restaurant = Restaurant.find(restaurant[:id])
    @restaurant.destroy
    redirect_to restaurants_path
  end

  protected

  def restaurant_params
    params.require(:restaurant).permit(
      :name, :address, :price_range, :cuisine, :city
      )
  end

end
