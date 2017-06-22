class ChangeRowNameForOutKuduDetails < ActiveRecord::Migration
  def change
    rename_column :out_kudu_details, :source_id, :output_id
  end
end
