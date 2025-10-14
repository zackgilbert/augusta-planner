class MissionControlController < ActionController::Base
  http_basic_authenticate_with(
    name: ENV["MISSION_CONTROL_USERNAME"] || "admin",
    password: ENV["MISSION_CONTROL_PASSWORD"] || "admin"
  )
end