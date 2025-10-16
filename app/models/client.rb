class Client < ApplicationRecord
  # 🚅 add concerns above.

  # 🚅 add attribute accessors above.

  belongs_to :team
  belongs_to :creator, class_name: "Membership", optional: true
  # 🚅 add belongs_to associations above.

  has_many :agreements, dependent: :destroy, enable_cable_ready_updates: false
  # 🚅 add has_many associations above.

  # 🚅 add has_one associations above.

  # 🚅 add scopes above.

  validates :creator, scope: true, unless: :public_intake?
  validates :ein, presence: true
  validates :business_name, presence: true
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
