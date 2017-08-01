class KuduTableColumns < ActiveRecord::Base

  belongs_to :table, class_name: 'KuduTable', foreign_key: 'table_id'

  DEFAULT_NAME = "none"
  TYPES = %w(string int bigint boolean float double)

end
