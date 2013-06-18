require 'coveralls'
require 'webmock/rspec'
 
Coveralls.wear!

RSpec.configure do |config|
    config.include WebMock
end

