# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!

client = Yelp::Client.new({ consumer_key: YOUR_CONSUMER_KEY,
                            consumer_secret: YOUR_CONSUMER_SECRET,
                            token: YOUR_TOKEN,
                            token_secret: YOUR_TOKEN_SECRET
                          })

IGNORE ME!