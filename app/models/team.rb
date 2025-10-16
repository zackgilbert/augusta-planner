class Team < ApplicationRecord
  include Teams::Base
  include Webhooks::Outgoing::TeamSupport

  # 🚅 add concerns above.

  # 🚅 add belongs_to associations above.

  has_many :clients, dependent: :destroy, enable_cable_ready_updates: false
  # 🚅 add has_many associations above.

  # 🚅 add oauth providers above.

  # 🚅 add has_one associations above.

  # 🚅 add scopes above.

  # 🚅 add validations above.

  # 🚅 add callbacks above.

  # 🚅 add delegations above.

  def is_staff?
    staff_team_id = ENV.fetch("STAFF_TEAM_ID", nil)
    staff_team_id.present? && id.to_s == staff_team_id
  end

  # 🚅 add methods above.
end
