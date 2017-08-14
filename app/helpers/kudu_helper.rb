module KuduHelper
  def table_in_db?(name)
    !KuduTable.where(name: name).first.blank?
  end
end
