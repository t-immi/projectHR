class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :hh_id, null: false
      t.string :email
      t.string :name
      t.text :access_token
      t.text :refresh_token
      t.datetime :expires_at

      t.timestamps
    end

    add_index :users, :hh_id, unique: true
    add_index :users, :email
  end
end
