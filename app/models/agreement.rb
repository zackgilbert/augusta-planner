class Agreement < ApplicationRecord
  # 🚅 add concerns above.

  # 🚅 add attribute accessors above.
  store_accessor :data, :owner_name, :owner_email

  belongs_to :client
  belongs_to :creator, class_name: "Membership", optional: true
  # 🚅 add belongs_to associations above.

  has_many :events, dependent: :destroy, enable_cable_ready_updates: false
  accepts_nested_attributes_for :events, allow_destroy: true, reject_if: :all_blank
  # 🚅 add has_many associations above.

  has_one :team, through: :client
  # 🚅 add has_one associations above.

  # 🚅 add scopes above.

  validates :creator, scope: true, unless: :public_intake?
  validates :year, presence: true
  validates :property_address, presence: true
  # 🚅 add validations above.

  # 🚅 add callbacks above.

  # 🚅 add delegations above.

  def valid_creators
    team.memberships
  end

  def public_intake?
    creator_id.nil?
  end

  # 🚅 add methods above.
end
