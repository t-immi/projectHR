class AddHhFieldsToVacancies < ActiveRecord::Migration[8.1]
  def change
    add_column :vacancies, :hh_external_id, :string
    add_index :vacancies, :hh_external_id, unique: true, where: "hh_external_id IS NOT NULL"
  end
end
