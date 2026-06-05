class CreateResumes < ActiveRecord::Migration[8.1]
  def change
    create_table :resumes do |t|
      t.string :title, null: false
      t.text :body, null: false
      t.string :source, null: false, default: "upload"
      t.string :hh_external_id

      t.timestamps
    end

    add_index :resumes, :hh_external_id, unique: true, where: "hh_external_id IS NOT NULL"
    add_index :resumes, :source
  end
end
