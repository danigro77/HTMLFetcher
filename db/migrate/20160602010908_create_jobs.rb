class CreateJobs < ActiveRecord::Migration
  def change
    create_table :jobs do |t|
      t.integer :page_resource_id
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
