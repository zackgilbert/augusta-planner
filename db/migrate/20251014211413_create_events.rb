class CreateEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :events do |t|
      t.references :agreement, null: false, foreign_key: true
      t.references :creator, foreign_key: {to_table: "memberships"}
      t.string :event_type, null: false
      t.date :event_date_on
      t.integer :market_rate_amount
      t.jsonb :data, null: false, default: {}

      t.timestamps
    end
  end
end
