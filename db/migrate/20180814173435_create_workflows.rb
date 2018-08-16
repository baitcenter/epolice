class CreateWorkflows < ActiveRecord::Migration[5.2]
  def change
    create_table :workflows do |t|
      t.string :status
      t.string :document

      t.timestamps
    end
  end
end
