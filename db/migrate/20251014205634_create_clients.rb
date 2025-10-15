class CreateClients < ActiveRecord::Migration[8.0]
  def change
    create_table :clients do |t|
      t.references :team, null: false, foreign_key: true
      t.references :creator, foreign_key: {to_table: "memberships"}
      t.string :business_name, null: false
      t.string :ein, null: false
      t.jsonb :data, null: false, default: {}

      t.timestamps
    end
    add_index :clients, :ein, unique: true
  end
end
