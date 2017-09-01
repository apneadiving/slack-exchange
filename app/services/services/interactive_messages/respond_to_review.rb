module Services
  module InteractiveMessages
    class RespondToReview < Services::BaseResponse

      def call
        if accepted?
          ::RestClient.post "https://slack.com/api/chat.postEphemeral", {
            	token: ENV['ACCESS_TOKEN'] ,
              channel: channel_id,
              text: "Hi <@#{user_id}>. Here is the link to PR: #{pull_request_url}",
              user: user_id
          }
          ::RestClient.post "https://slack.com/api/chat.postEphemeral", {
            	token: ENV['ACCESS_TOKEN'] ,
              channel: channel_id,
              text: "Hey <@#{requester_id}, your PR is reviewed by <@#{user_id}>",
              user: requester_id
          }
          #review_request.update(discarded_user_ids: [])
        else
          review_request.update(discarded_user_ids: review_request.discarded_user_ids + [user_id])

          ::Services::Commands::Review.new({
            team_id:      team_id,
            user_id:      requester_id,
            channel_id:   channel_id,
            args:         pull_request_url,
            response_url: response_url
          }).call
        end
      end

      private

      def review_request
        @review_request ||= ::ReviewRequest.find(review_request_id)
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

      def pull_request_url
        review_request.pull_request_url
      end

      def accepted?
        answer == 'yes'
      end

      def requester_id
        review_request.slack_user_id
      end
    end
  end
end
