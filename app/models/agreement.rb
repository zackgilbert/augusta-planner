class Agreement < ApplicationRecord
  # 🚅 add concerns above.

  # 🚅 add attribute accessors above.

  belongs_to :client
  belongs_to :creator, class_name: "Membership"
  # 🚅 add belongs_to associations above.

  # 🚅 add has_many associations above.

  has_one :team, through: :client
  # 🚅 add has_one associations above.

  # 🚅 add scopes above.

  validates :creator, scope: true
  validates :year, presence: true
  # 🚅 add validations above.

  # 🚅 add callbacks above.

  # 🚅 add delegations above.

  def valid_creators
    team.memberships
  end

  # 🚅 add methods above.
end
