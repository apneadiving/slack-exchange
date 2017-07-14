class AddLatestReviewerSlackIdToReviewRequests < ActiveRecord::Migration[5.1]
  def change
    add_column :review_requests, :latest_reviewer_slack_id, :string
  end
end
