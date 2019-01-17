# https://guides.rubyonrails.org/rails_application_templates.html
# https://edgeguides.rubyonrails.org/generators.html
# https://multithreaded.stitchfix.com/blog/2014/01/06/rails-app-templates/

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
gem 'oj', '~> 2.16.1'
gem 'whenever', require: false

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

gsub_file "Gemfile", /^gem\s+["']sqlite3["'].*$/,''
gsub_file "Gemfile", /^gem\s+["']turbolinks["'].*$/,''
gsub_file "Gemfile", /^gem\s+["']coffee-rails["'].*$/,''
gsub_file "Gemfile", /^gem\s+["']sass-rails["'].*$/,''
gsub_file "Gemfile", /^gem\s+["']spring["'].*$/,''
gsub_file "Gemfile", "# Use SCSS for stylesheets",''
gsub_file "Gemfile", "# Use sqlite3 as the database for Active Record",''
gsub_file "Gemfile", "# Use CoffeeScript for .coffee assets and views",''
gsub_file "Gemfile", "# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks",''

run "bundle"

# rspec
rails_command "generate rspec:install"

# devise
rails_command "generate devise:install"
environment 'config.action_mailer.default_url_options = {host: "http://yourwebsite.example.com"}', env: 'production'
environment 'config.action_mailer.default_url_options = {host: "localhost", port: 3000}', env: 'development'

# whenever
run "wheneverize ."

# bootstrap
run "mv app/assets/stylesheets/application.css app/assets/stylesheets/application.scss"
run "echo '@import \"bootstrap\";' > app/assets/stylesheets/application.scss"
run "echo '//= require jquery' > app/assets/javascripts/application.js"
run "echo '//= require rails-ujs' >> app/assets/javascripts/application.js"
run "echo '//= require activestorage' >> app/assets/javascripts/application.js"
run "echo '//= require popper' >> app/assets/javascripts/application.js"
run "echo '//= require bootstrap' >> app/assets/javascripts/application.js"
run "echo '//= require_tree .' >> app/assets/javascripts/application.js"

# capistrano
run "bundle exec cap install"
File.open('Capfile', 'w') do |file|
  file.write <<-TEXT
# Load DSL and set up stages
require "capistrano/setup"

# Include default deployment tasks
require "capistrano/deploy"

# Load the SCM plugin appropriate to your project:
#
# require "capistrano/scm/hg"
# install_plugin Capistrano::SCM::Hg
# or
# require "capistrano/scm/svn"
# install_plugin Capistrano::SCM::Svn
# or
require "capistrano/scm/git"
install_plugin Capistrano::SCM::Git

# Include tasks from other gems included in your Gemfile
#
# For documentation on these, see for example:
#
#   https://github.com/capistrano/rvm
#   https://github.com/capistrano/rbenv
#   https://github.com/capistrano/chruby
#   https://github.com/capistrano/bundler
#   https://github.com/capistrano/rails
#   https://github.com/capistrano/passenger
#
require "capistrano/rvm"
require "capistrano/bundler"
require "capistrano/rails/assets"
require "capistrano/rails/migrations"
require 'capistrano/puma'
install_plugin Capistrano::Puma

# Load custom tasks from `lib/capistrano/tasks` if you have any defined
Dir.glob("lib/capistrano/tasks/*.rake").each { |r| import r }

    TEXT
end

# database
File.open('config/database.yml', 'w') do |file|
  file.write <<-TEXT
default: &default
  adapter: postgresql
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  timeout: 5000

development:
  <<: *default
  database: db_development

test:
  <<: *default
  database: db_test

production:
  <<: *default
  database: db_production
    TEXT
end

# layout
File.open('app/views/layouts/application.slim', 'w') do |file|
  file.write <<-TEXT
doctype html
html
  head
    title = content_for?(:title) ? yield(:title) : 'My Project'
    meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no"

    / Twitter
    meta name="twitter:card" content="summary"
    meta name="twitter:title" content="\#{content_for?(:title) ? yield(:title) : 'My Project'}"
    meta name="twitter:description" content="\#{content_for?(:description) ? yield(:description) : 'Shared description'}"

    / Facebook
    meta property="og:site_name" content="My Project"
    meta property="og:title" content="\#{content_for?(:title) ? yield(:title) : 'My Project'}"
    meta property="og:description" content="\#{content_for?(:description) ? yield(:description) : 'Shared description'}"

    / Other
    title = content_for?(:title) ? yield(:title) : 'My Project'
    meta name="description" content="\#{content_for?(:description) ? yield(:description) : 'Shared description'}"

    = csrf_meta_tags
    = csp_meta_tag
    link rel="icon" href="/favicon.ico"
    = stylesheet_link_tag    'application', media: 'all'
    = javascript_include_tag 'application'
    link href="https://fonts.googleapis.com/css?family=Roboto" rel="stylesheet"

  body
    - if flash[:notice]
      .alert.alert-success = notice
    - if flash[:alert]
      .alert.alert-warning = alert
    = yield
  TEXT
end
run "rm app/views/layouts/application.html.erb"

# root controller
generate(:controller, "welcome", "index", "--skip-routes", "--no-helper")
route "root to: 'welcome#index'"

# active_admin
rails_command "generate active_admin:install"
# rails_command "generate active_admin:resource User"

# rollbar
rails_command "generate rollbar POST_SERVER_ITEM_ACCESS_TOKEN"
inject_into_file 'config/initializers/rollbar.rb', after: "config.access_token = 'POST_SERVER_ITEM_ACCESS_TOKEN'\n" do <<-RUBY
  config.exception_level_filters.merge!(
    'ActionController::RoutingError' => 'ignore',
    'AbstractController::ActionNotFound' => 'ignore',
    'ActiveRecord::RecordNotFound' => 'ignore'
  )
RUBY
end

# simple form
rails_command "generate simple_form:install --bootstrap"


rails_command "db:migrate"

# gitignore
run "echo '.idea' >> .gitignore"
run "echo '*.iml' >> .gitignore"

git :init
git add: "."
git commit: "-a -m 'Initial commit'"



