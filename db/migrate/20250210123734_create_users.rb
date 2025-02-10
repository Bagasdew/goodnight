class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :name

      t.timestamps

      t.index :name, :unique => true
    end
  end
end
