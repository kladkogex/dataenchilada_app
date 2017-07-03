class RenameRowForOutForwardDetails < ActiveRecord::Migration
  def change
    rename_column :out_forward_details, :source_id, :output_id
    rename_column :out_forward_details, :brokers, :send_timeout
    rename_column :out_forward_details, :topics, :recover_wait
    rename_column :out_forward_details, :format, :heartbeat_interval
  end
end
