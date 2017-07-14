module Services
  class GetAuthUrl

    include ::Services::Oauth

    SCOPES = ['users:read', 'chat:write:bot', 'channels:read', 'incoming-webhook', 'commands'].join(',')
    AUTHORIZATION_URL = 'https://slack.com/oauth/authorize'

    def call
      uri = URI(AUTHORIZATION_URL)
      uri.query = {
        client_id: client_id,
        scope:     SCOPES
      }.to_query
      uri.to_s
    end
  end
end
