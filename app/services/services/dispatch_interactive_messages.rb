module Services
  class DispatchInteractiveMessages

    include Waterfall
    include ActiveModel::Validations

    validate :known_message
    validate :validate_token

    MAPPING = {
      "reviewer_assessment" => {
        worker_class: ::Services::InteractiveMessages::ReviewerAssessment
      },
      "respond_to_review" => {
        worker_class: ::Services::InteractiveMessages::RespondToReview
      }
    }

    def initialize(params:)
      @params = params
      @message = MAPPING[params['callback_id']] || {}
    end

    def call
      when_falsy { valid? }
        .dam { errors }
      chain { enqueue_command }
    end

    private

    attr_reader :params, :message

    def enqueue_command
      Resque.enqueue message[:worker_class], {
        team_id:      params['team']['id'],
        user_id:      params['user']['id'],
        channel_id:   params['channel']['id'],
        args:         params['actions'],
        response_url: params['response_url']
      }
    end

    def known_message
      add_error("unknown message") if message.blank?
    end

    def validate_token
      add_error("invalid token") unless verification_token == params['token']
    end

    def add_error(text)
      errors.add :SDI, text
    end

    def verification_token
      ENV['SLACK_TOKEN']
    end
  end
end
