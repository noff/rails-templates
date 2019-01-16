gem 'pg'
gem 'puma', '~> 3.11'
gem 'sassc-rails'
gem 'slim-rails'
gem 'simple_form'
gem 'uglifier', '>= 1.3.0'
gem 'bootstrap', '~> 4.1.3'
gem 'country_select', '~> 3.1'
gem 'jquery-rails'
gem 'activeadmin'
gem 'devise'
gem 'rollbar'

gem_group :development do
  gem 'capistrano', '~> 3.11.0'
  gem 'capistrano-rvm'
  gem 'capistrano-rails'
  gem 'capistrano-bundler'
  gem 'letter_opener'
  gem 'capistrano3-puma'
end

gem_group :development, :test do
  gem 'rspec-rails', '~> 3.8'
end

run "bundle"

after_bundle do
  rails_command "db:migrate"

  # Install bootstrap
  # Install devise
  # Install capistrano
  # Install DB config
  # Convert application slim
  # Generate root controller
  # Generate Users resource for ActiveAdmin

  git :init
  git add: "."
  git commit: "-a -m 'Initial commit'"
end








# https://github.com/twbs/bootstrap-rubygem