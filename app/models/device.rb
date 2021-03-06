# == Schema Information
#
# Table name: devices
#
#  id            :integer          not null, primary key
#  name          :text
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  status_id     :integer
#  reference_url :text
#

class Device < ActiveRecord::Base
  attr_accessible :name, :tag, :status_id, :reference_url, :asset_code, :model, :category_id, :pat_date, :training_category_id, :provenance_id, :date_acquired, :value_when_acquired, :minor_item

  validates :name, presence: true

  has_many :asset_tags
  has_many :tickets

  belongs_to :category
  belongs_to :provenance
  belongs_to :status
  belongs_to :training_category

  has_and_belongs_to_many :maintainers, :class_name => User, :join_table => :devices_maintainers
  has_and_belongs_to_many :owners

  after_save :deliver_status_change_email

  def deliver_status_change_email
    if status_id_changed?
      maintainers.each do |maintainer|
        MaintenanceAlertMailer.status_change(maintainer, self).deliver
      end
    end
  end
end
