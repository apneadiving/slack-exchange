module Services
  class SetToken

    include ::Services::Oauth

    ACCESS_URL = 'https://slack.com/api/oauth.access'

    def initialize(code:)
      @code = code
    end

    def call
      hand_shake

      user.update({
        access_token:     response['access_token'],
        scope:            response['scope'],
        team_name:        response['team_name'],
        team_id:          response['team_id'],
        incoming_webhook: response['incoming_webhook']  # contains channel, channel_id, configuration_url, url
      })
    end

    private

    def hand_shake
      @response = JSON.parse(RestClient.get ACCESS_URL, {
        params: {
          client_id:     client_id,
          client_secret: client_secret,
          code:          code
        }
      })
    end

    def user
      @user ||= ::User.find_or_initialize_by(user_id: response['user_id'])
    end

    attr_reader :code, :response
  end
end
