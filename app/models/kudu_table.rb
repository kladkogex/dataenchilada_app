class KuduTable < ActiveRecord::Base

  has_many :columns, class_name: 'KuduTableColumns', foreign_key: 'table_id', :dependent => :destroy
  accepts_nested_attributes_for :columns, reject_if: :all_blank, allow_destroy: true

  validates :name, presence: true, uniqueness: true

end
