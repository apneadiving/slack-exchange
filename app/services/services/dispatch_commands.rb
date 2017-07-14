module Services
  class DispatchCommands

    include Waterfall
    include ::ActiveModel::Validations

    validate :known_command
    validate :validate_token

    MAPPING = {
      "/review" => {
        worker_class: ::Services::Commands::Review
      }
    }

    def initialize(params:)
      @params = params
      @command = MAPPING[params[:command]] || {}
    end

    def call
      when_falsy { valid? }
        .dam { errors }
      chain { enqueue_command }
    end

    private

    attr_reader :params, :command

    def enqueue_command
      Resque.enqueue command[:worker_class], {
        team_id:      params[:team_id],
        user_id:      params[:user_id],
        channel_id:   params[:channel_id],
        args:         params[:text],
        response_url: params[:response_url]
      }
    end

    def known_command
      add_error("unknown command") if command.blank?
    end

    def validate_token
      add_error("invalid token") unless verification_token == params[:token]
    end

    def add_error(text)
      errors.add :SDP, text
    end

    def verification_token
      ENV['SLACK_TOKEN']
    end
  end
end
