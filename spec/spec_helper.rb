require 'coveralls'
require 'webmock/rspec'
 
Coveralls.wear!

Spec::Runner.configure do |config|
    config.include WebMock
end

