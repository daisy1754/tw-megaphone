class CreateRules < ActiveRecord::Migration[6.0]
  def change
    create_table :rules do |t|
      t.string :rule_type
      t.string :value
      t.integer :score
      t.references :user, index: true

      t.timestamps
    end
  end
end
