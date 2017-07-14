module Services
  module InteractiveMessages
    class ReviewerAssessment < Services::BaseResponse

      def call

        binding.pry
        if accepted?
          ::RestClient.post "https://slack.com/api/chat.postMessage", {
            text:   "Review! <@#{reviewer_slack_id}>",
            attachments: [
             {
              text:     "Do you agree?",
              fallback: "duh",
              callback_id: "respond_to_review",
              attachment_type: "default",
              actions: [
                {
                  name:  "yes",
                  text:  "Yes",
                  type:  "button",
                  value: "yes|#{review_request.id}",
                  style: "primary"
                },
                {
                  name:  "no",
                  text:  "No",
                  type:  "button",
                  value: "no|#{review_request.id}"
                }
              ]
            }],
            replace_original: true,
            token:   user.access_token,
            channel: channel_id
          }
        else
          review_request.update(discarded_user_ids: review_request.discarded_user_ids + [reviewer_slack_id])

          ::Services::Commands::Review.new({
            team_id:      team_id,
            user_id:      user_id,
            channel_id:   channel_id,
            args:         pull_request_url,
            response_url: response_url
          }).call
        end
      end

      private

      def review_request
        @review_request ||= ::ReviewRequest.find review_request_id
      end

      def arg_chunks
        @arg_chunks ||= args.first['value'].split('|')
      end

      def answer
        arg_chunks[0]
      end

      def review_request_id
        arg_chunks[1]
      end

      def reviewer_slack_id
        review_request.latest_reviewer_slack_id
      end

      def pull_request_url
        review_request.pull_request_url
      end

      def accepted?
        answer == 'yes'
      end
    end
  end
end
