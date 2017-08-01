class KuduTable < ActiveRecord::Base

  has_many :columns, class_name: 'KuduTableColumns', foreign_key: 'table_id'
  accepts_nested_attributes_for :columns, reject_if: :all_blank, allow_destroy: true

end
