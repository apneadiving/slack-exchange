module Services
  module Commands
    class Review < Services::BaseResponse

      def call
        find_or_create_review_request
        reviewer_id = possible_reviewer_ids.sample

        if reviewer_id
          review_request.update!({ latest_reviewer_slack_id: reviewer_id })
          post({
            text: "Would ping <@#{reviewer_id}>",
            attachments: [
             {
              text:     "Do you want to confirm?",
              fallback: "duh",
              callback_id: "reviewer_assessment",
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
            replace_original: true
          })
        else
          post({
            text: "Sorry we could not find a match for the review"
          })
        end
      end

      private

      attr_reader :review_request

      # timezone: optional param?
      # buttons: ok, ko  can/cannot do => reroll the review stuff
      # auto-ko is not ok within X minutes


      # attr_reader :team_id, :user_id, :args, :response_url, :channel_id

      # message formatting:
      # - https://api.slack.com/docs/message-formatting
      # - https://api.slack.com/docs/message-attachments
      # {response_type: "in_channel"}
      def post(response)
        ::RestClient.post response_url, response.to_json, { content_type: :json }
      end

      def pull_request_url
        args
      end

      def find_or_create_review_request
        @review_request = ::ReviewRequest.find_or_create_by(
          slack_user_id:    user_id,
          pull_request_url: pull_request_url
        )
      end

      def possible_reviewer_ids
        whitelisted_user_ids & all_active_users_ids
      end

      def all_active_users_ids
        @all_active_users_ids ||= begin
          response = ::RestClient.post "https://slack.com/api/users.list", { token: user.access_token, presence: true }
          raise StandardError unless response.code == 200
          members = JSON.parse(response.body)["members"]

          members.each_with_object([]) do |member, array|
            array.push(member["id"]) if is_eligible?(member)
          end
        end
      end

      def is_eligible?(member)
        member["presence"] == "active"
      end

      def whitelisted_user_ids
        channel_user_ids - review_request.discarded_user_ids # - [ user_id ]
      end

      def channel_user_ids
        response = ::RestClient.post "https://slack.com/api/channels.info", { token: user.access_token, channel: channel_id }
        raise StandardError unless response.code == 200
        @channel_info = JSON.parse(response.body)["channel"]["members"]
      end
    end
  end
end
