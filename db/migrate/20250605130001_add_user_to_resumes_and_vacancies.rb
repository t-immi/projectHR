class AddUserToResumesAndVacancies < ActiveRecord::Migration[8.1]
  def change
    add_reference :resumes, :user, foreign_key: true
    add_reference :vacancies, :user, foreign_key: true
  end
end
