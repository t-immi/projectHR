class CreateVacancies < ActiveRecord::Migration[8.1]
  def change
    create_table :vacancies do |t|
      t.string :title, null: false
      t.text :body, null: false
      t.string :source, null: false, default: "upload"

      t.timestamps
    end

    add_index :vacancies, :source
  end
end
