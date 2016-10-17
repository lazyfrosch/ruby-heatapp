require 'heatapp'

module Heatapp
  # Error if an API request is unexpected
  class UnexpectedResponseError < StandardError
    def default_message
      'Received unexpected response from the API'
    end
  end

  # Error for failures during login
  class LoginFailedError < StandardError
    def default_message
      'Login to Heatapp failed'
    end
  end

  # Error when not authenticated
  class NotAuthenticatedError < StandardError
    def default_message
      'You are not authenticated currently'
    end
  end
end
