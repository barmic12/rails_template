remove_file "Gemfile"
file "Gemfile", %{
source 'https://rubygems.org'

ruby '2.6.2'

gem 'bootsnap', '>= 1.1.0', require: false
gem 'dotenv-rails'
gem 'envied'
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 3.11'
gem 'rails', '#{Rails::VERSION::STRING}'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
group :test do
  gem "capybara"
  gem "database_cleaner"
end
group :test, :development do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'rspec-rails'
  gem 'shoulda-matchers'
end
group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
}.strip


generate "rspec:install"

inject_into_file 'spec/rails_helper.rb', :after => "require 'rspec/rails'" do
  <<-eos
  \n
Dir[Rails.root.join('spec', 'support', '**', '*.rb')].each { |f| require f }
  eos
end

file "spec/support/database_cleaner.rb", %{
require 'database_cleaner'

DatabaseCleaner.strategy = :truncation
DatabaseCleaner.clean
}.strip

file "spec/support/factory_bot.rb", %{
require 'factory_bot_rails'
RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
end
}.strip

file "spec/support/shoulda_matchers.rb", %{
require 'shoulda-matchers'

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
}.strip

remove_file "config/database.yml"

file "config/database.sample.yml", %{
default: &default
  adapter: postgresql
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  timeout: 5000
  username: <%= ENVied.DATABASE_USERNAME %>
  password: <%= ENVied.DATABASE_PASSWORD %>

development:
  <<: *default
  database: #{app_name}_development

test:
  <<: *default
  database: #{app_name}_test
}.strip

inject_into_file "config/application.rb", after: 'Bundler.require(*Rails.groups)' do
  <<-eos

Dotenv::Railtie.load
ENVied.require(*ENV['ENVIED_GROUPS'] || Rails.groups)
  eos
end

file "Envfile", %{
variable :DATABASE_USERNAME, :string
variable :DATABASE_PASSWORD, :string
}.strip

file ".env.sample", %{
DATABASE_USERNAME=USERNAME
DATABASE_PASSWORD=PASSWORD
}.strip

append_to_file ".gitignore" do
  <<-eos

config/database.yml
  eos
end
