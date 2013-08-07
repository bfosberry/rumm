require "mvcli/app"
require "rumm/version"
require 'rumm/exceptions'

module Rumm
  class App < MVCLI::App
    self.root = Pathname(__FILE__).dirname
  end
end
