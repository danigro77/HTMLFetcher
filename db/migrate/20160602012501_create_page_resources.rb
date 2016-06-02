class CreatePageResources < ActiveRecord::Migration
  def change
    create_table :page_resources do |t|
      t.string :url
      t.text :html
      t.integer :popularity, default: 1

      t.timestamps
    end
  end
end
