class CreateKuduTablesAndColumns < ActiveRecord::Migration
  def change
    create_table :kudu_tables do |t|
      t.string :name, null: false

      t.timestamps
    end

    create_table :kudu_table_columns do |t|
      t.integer :table_id, null: false
      t.string :name, null: false
      t.string :type, null: false
      t.boolean :primary_key, default: false
    end
  end

end
