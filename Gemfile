source 'https://rubygems.org'

gem 'rails', '3.2.16'

gem "mongoid", "~> 3.1.6"
gem "origin"
gem "aasm", "~> 3.0.25"
gem "nokogiri", "~> 1.6.1"
gem "bunny"

gem 'jquery-rails'
gem 'jquery-ui-rails'

group :development do
  gem 'capistrano', '2.15.4'
  gem 'ruby-progressbar'
end

group :development, :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  gem 'uglifier', '>= 1.0.3'

  gem 'therubyracer', :platforms => :ruby
  gem 'less-rails-bootstrap'
  gem 'designmodo-flatuipro-rails', '~> 1.2.5.0.branch'
  gem 'font-awesome-rails'

end

group :development, :test do
	gem 'mongoid-rspec'
  gem 'rspec-rails' #, '~> 3.0.0.beta'
  gem 'capybara'
  gem "capybara-webkit"
  gem 'factory_girl_rails'
  gem 'database_cleaner'
end

gem 'simple_form'
gem "haml"
gem 'kaminari'
gem 'bootstrap-kaminari-views'
gem "pd_x12"
gem 'carrierwave-mongoid', :require => 'carrierwave/mongoid'
gem 'devise'
gem "rsec"
gem "mongoid_auto_increment"
gem 'american_date'

group :production do
  gem 'unicorn'
end

gem 'oj'
