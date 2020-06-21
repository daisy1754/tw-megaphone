class CreateExports < ActiveRecord::Migration[6.0]
  def change
    create_table :exports do |t|
      t.references :user, index: true
      t.string :file_name
      t.integer :num_items
      t.integer :num_current, default: 0
      t.boolean :completed

      t.timestamps
    end
  end
end
