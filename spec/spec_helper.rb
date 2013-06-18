require 'coveralls'
require 'webmock/rspec'
 
Coveralls.wear!

RSpec.configure do |config|
  include WebMock::API
end

