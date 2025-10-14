class Team < ApplicationRecord
  include Teams::Base
  include Webhooks::Outgoing::TeamSupport

  # 🚅 add concerns above.

  # 🚅 add belongs_to associations above.

  # 🚅 add has_many associations above.

  # 🚅 add oauth providers above.

  has_one :client, dependent: :destroy
  # 🚅 add has_one associations above.

  # 🚅 add scopes above.

  # 🚅 add validations above.

  # 🚅 add callbacks above.

  # 🚅 add delegations above.

  def is_staff?
    id.to_s == ENV["STAFF_TEAM_ID"]
  end

  # 🚅 add methods above.
end
