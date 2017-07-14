class ReviewRequest < ApplicationRecord

  serialize :discarded_user_ids, Array

  scope :from_user_id, ->(slack_user_id) { where(slack_user_id: slack_user_id)}

  def self.latest_from(slack_user_id)
    from_user_id(slack_user_id).order(created_at: :desc).first
  end
end
