module Services
  class BaseResponse
    cattr_accessor :queue do
      :slack_commands
    end

    def self.perform(params)
      self.new(params.with_indifferent_access).call
    end

    def initialize(params)
      @team_id      = params[:team_id]
      @user_id      = params[:user_id]
      @channel_id   = params[:channel_id]
      @args         = params[:args]
      @response_url = params[:response_url]
    end

    def call
      raise NotImplementedError
    end

    private

    attr_reader :team_id, :user_id, :args, :response_url, :channel_id

    def user
      @user ||= User.find_by team_id: team_id
    end

    # message formatting:
    # - https://api.slack.com/docs/message-formatting
    # - https://api.slack.com/docs/message-attachments
    def post(response)
      ::RestClient.post response_url, response.to_json, { content_type: :json }
    end
  end
end