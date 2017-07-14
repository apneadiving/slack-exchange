class CreateReviewRequests < ActiveRecord::Migration[5.1]
  def change
    create_table :review_requests do |t|
      t.string :slack_user_id
      t.string :pull_request_url
      t.text :discarded_user_ids

      t.timestamps
    end
  end
end
