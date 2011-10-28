require "rubygems"
require "bundler/setup"
require "rspec"

RSpec.configure do |config|
      config.color_enabled = true
end

Dir.glob(File.join(File.dirname(__FILE__), 'tests', '**', '*.rb')).each {|f| require f }
