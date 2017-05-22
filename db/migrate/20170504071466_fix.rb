class Fix < ActiveRecord::Migration
  def change
    rename_column :out_file_details, :source_id, :output_id
  end
end
