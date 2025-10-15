class CreateAgreements < ActiveRecord::Migration[8.0]
  def change
    create_table :agreements do |t|
      t.references :client, null: false, foreign_key: true
      t.references :creator, foreign_key: {to_table: "memberships"}
      t.integer :year, null: false
      t.string :status, null: false, default: "draft"
      t.text :property_address, null: false, default: ""
      t.jsonb :data, null: false, default: {}

      t.timestamps
    end
    add_index :agreements, [:client_id, :year], unique: true
  end
end
