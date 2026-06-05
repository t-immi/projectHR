class CreateMatchScores < ActiveRecord::Migration[8.1]
  def change
    create_table :match_scores do |t|
      t.references :resume, null: false, foreign_key: true
      t.references :vacancy, null: false, foreign_key: true
      t.decimal :score, precision: 5, scale: 4, null: false
      t.string :computed_by, null: false, default: "ml_model"

      t.timestamps
    end

    add_index :match_scores, %i[resume_id vacancy_id], unique: true
    add_index :match_scores, :score
  end
end
