class AddRowForOutKuduDetails < ActiveRecord::Migration
  def change
    add_column :out_kudu_details, :flume_sink_port, :integer
    add_column :out_kudu_details, :master_host, :string
    add_column :out_kudu_details, :master_port, :string
  end
end
