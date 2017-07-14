module Services
  module Oauth
    def client_id
      ENV['SLACK_CLIENT_ID']
    end

    def client_secret
      ENV['SLACK_CLIENT_SECRET']
    end
  end
end
