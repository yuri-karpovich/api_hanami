# frozen_string_literal: true

require './app/initializer'
require './app/app'

# Accept JSON from request body as well
use Hanami::Middleware::BodyParser, :json

run App.new
