require 'capybara'
require 'capybara/dsl'

module Capybara
  module Unit
    def enable_javascript
      Capybara.current_driver = Capybara.javascript_driver
    end

    def reset_sessions!
      Capybara.reset_sessions!
    end
  end
end

