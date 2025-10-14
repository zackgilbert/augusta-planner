puts "🌱 Generating development environment seeds."

default_timezone = "Central Time (US & Canada)"

ActiveRecord::Base.transaction do
  # create staff team without which the app will not work, see is_staff? method inside app/models/team.rb
  team = Team.find_or_create_by(name: "Augusta Planner") do |t|
    t.time_zone = default_timezone
  end

  # Update the STAFF_TEAM_ID environment variable if it doesn't match
  unless ENV["STAFF_TEAM_ID"] == team.id.to_s
    puts "📝 Note: Staff Team ID is #{team.id}. You may want to set STAFF_TEAM_ID=#{team.id} in your environment."
  end

  user =
    User.find_or_create_by(email: ENV.fetch("SUPPORT_EMAIL", "default@example.com")) do |u|
      u.password = ENV.fetch("DEFAULT_PASSWORD", SecureRandom.hex)
      u.current_team_id = team.id
      u.first_name = "Default"
      u.last_name = "User"
      u.time_zone = default_timezone
    end

  membership =
    Membership.find_or_create_by(team_id: team.id, user_id: user.id) do |m|
      m.user_email = user.email
      m.role_ids = ["admin"]
    end

  # Ensure membership is saved
  membership.save! unless membership.persisted?

  puts "Welcome to the #{team.name} team, #{user.first_name}: #{membership.persisted?} // #{team.memberships.reload.inspect}"
end
