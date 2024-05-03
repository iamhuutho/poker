class CreateNewpokers < ActiveRecord::Migration[7.1]
  def change
    create_table :newpokers do |t|
      t.string :cards
      t.timestamps
    end
  end
end
