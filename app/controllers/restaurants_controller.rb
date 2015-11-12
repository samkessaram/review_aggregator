class RestaurantsController < ApplicationController

  def index
    if $error == "No Results"
      $error = "We couldn't find a restaurant matching that name, check the spelling and try again."
    end
  end

  def reviews
    $error = nil
    if params[:location]
      @city = params[:location]
      @response = Yelp.client.search( @city, { term: params[:term], limit: 5 })
      if @response.total == 0
        $error = "We couldn't find a restaurant matching that name, check the spelling and try again."
        redirect_to '/'
      end
    end

    @yelp_restaurant = Yelp.client.business(@response.businesses[0].id)

    yelp_url = @yelp_restaurant.url
    headers = {
          # "ACCEPT"=>"text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
          # "ACCEPT_ENCODING" => "gzip, deflate, sdch",
          # "ACCEPT_LANGUAGE" => "en-US,en;q=0.8",
          # "CONNECTION" => "keep-alive",
          # # "HOST"=>"http://www.yelp.com/",
          # "UPGRADE_INSECURE_REQUESTS"=>"1",
          # "USER_AGENT" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2490.80 Safari/537.36"
          }

    yelp = HTTParty.get(yelp_url, :headers=> headers)
    yelp_page = Nokogiri::HTML(yelp)
    yelp_reviews = yelp_page.css('.review-list p').to_s.split('voting-intro voting-prompt')
    @yelp_ratings = yelp_page.css('div.review--with-sidebar div.review-content i.star-img').to_s.split("title=\"")

    @yelp_ratings.map! do |rating| 
      if rating.include?(" star rating")
        rating.split(" star rating")[0]
      end
    end

    @yelp_ratings.compact!

    @yelp_reviews = []

    yelp_reviews.map! do |review|
      if review.include? ("en")
        review.split("lang=\"en\">")[1].split("</p>")[0]
      end
    end

    @yelp_dates = yelp_page.css('div span.rating-qualifier').to_s.split("datePublished\" content=\"")[1..3].map { |date| date = date[0..9]}

    yelp_reviews.compact!
    yelp_reviews.each { |x| !x.include?('<p>') ? @yelp_reviews << x.split("</p>")[0] : x = nil }

    zomato_city_id = 89 #Toronto
    @zomato_restaurant = HTTParty.get('https://developers.zomato.com/api/v2.1/search?q=' + @yelp_restaurant.name.downcase.gsub(' ','+') + '&count=1&lat=' + @yelp_restaurant.location.coordinate.latitude.to_s + '&lon=' + @yelp_restaurant.location.coordinate.longitude.to_s, :headers => {'user_key' => @@ZOMATO_KEY})["restaurants"][0]["restaurant"]
    @zomato_url = @zomato_restaurant["url"]

    open_table_url = "http://www.opentable.com/" + @zomato_restaurant["name"].downcase.gsub(' ','-')
    open_table = HTTParty.get(open_table_url, :headers=> headers)
    open_table_page = Nokogiri::HTML(open_table)
    @open_table_reviews = open_table_page.css('#reviews-page p').to_s.split('</p>')
    @open_table_ratings = open_table_page.css('#reviews-results div.all-stars').to_s.split("title=\"")[1..3].map {|s| s = s[0].split("\" class")[0]}
    @open_table_dates = open_table_page.css('#reviews-results div.review-meta > span').to_s.split("color-light\">")[1..3].map { |date| date.split("<")[0] }
    # binding.pry
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
