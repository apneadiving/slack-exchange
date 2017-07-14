class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :access_token
      t.string :user_id
      t.string :team_name
      t.string :team_id
      t.string :scope
      t.text :incoming_webhook

      t.timestamps
    end
  end
end
