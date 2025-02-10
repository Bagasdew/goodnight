class CreatePresences < ActiveRecord::Migration[7.1]
  def change
    create_table :presences do |t|
      t.references :user, null: false, foreign_key: true
      t.datetime :clock_in, null: false
      t.datetime :clock_out, null: true

      t.timestamps
    end

    add_index :presences, %w[clock_in clock_out]
  end
end
