require "controllers/api/v1/test"

class Api::V1::EventsControllerTest < Api::Test
  setup do
    # See `test/controllers/api/test.rb` for common set up for API tests.

    @client = create(:client, team: @team)
    @agreement = create(:agreement, client: @client)
    @event = build(:event, agreement: @agreement)
    @other_events = create_list(:event, 3)

    @another_event = create(:event, agreement: @agreement)

    # 🚅 super scaffolding will insert file-related logic above this line.
    @event.save
    @another_event.save

    @original_hide_things = ENV["HIDE_THINGS"]
    ENV["HIDE_THINGS"] = "false"
    Rails.application.reload_routes!
  end

  teardown do
    ENV["HIDE_THINGS"] = @original_hide_things
    Rails.application.reload_routes!
  end

  # This assertion is written in such a way that new attributes won't cause the tests to start failing, but removing
  # data we were previously providing to users _will_ break the test suite.
  def assert_proper_object_serialization(event_data)
    # Fetch the event in question and prepare to compare it's attributes.
    event = Event.find(event_data["id"])

    assert_equal_or_nil event_data["creator_id"], event.creator_id
    assert_equal_or_nil event_data["event_type"], event.event_type
    assert_equal_or_nil Date.parse(event_data["event_date_on"]), event.event_date_on
    assert_equal_or_nil event_data["market_rate_amount"], event.market_rate_amount
    # 🚅 super scaffolding will insert new fields above this line.

    assert_equal event_data["agreement_id"], event.agreement_id
  end

  test "index" do
    # Fetch and ensure nothing is seriously broken.
    get "/api/v1/agreements/#{@agreement.id}/events", params: {access_token: access_token}
    assert_response :success

    # Make sure it's returning our resources.
    event_ids_returned = response.parsed_body.map { |event| event["id"] }
    assert_includes(event_ids_returned, @event.id)

    # But not returning other people's resources.
    assert_not_includes(event_ids_returned, @other_events[0].id)

    # And that the object structure is correct.
    assert_proper_object_serialization response.parsed_body.first
  end

  test "show" do
    # Fetch and ensure nothing is seriously broken.
    get "/api/v1/events/#{@event.id}", params: {access_token: access_token}
    assert_response :success

    # Ensure all the required data is returned properly.
    assert_proper_object_serialization response.parsed_body

    # Also ensure we can't do that same action as another user.
    get "/api/v1/events/#{@event.id}", params: {access_token: another_access_token}
    assert_response :not_found
  end

  test "create" do
    # Use the serializer to generate a payload, but strip some attributes out.
    params = {access_token: access_token}
    event_data = JSON.parse(build(:event, agreement: nil).api_attributes.to_json)
    event_data.except!("id", "agreement_id", "created_at", "updated_at")
    params[:event] = event_data

    post "/api/v1/agreements/#{@agreement.id}/events", params: params
    assert_response :success

    # # Ensure all the required data is returned properly.
    assert_proper_object_serialization response.parsed_body

    # Also ensure we can't do that same action as another user.
    post "/api/v1/agreements/#{@agreement.id}/events",
      params: params.merge({access_token: another_access_token})
    assert_response :not_found
  end

  test "update" do
    # Post an attribute update ensure nothing is seriously broken.
    put "/api/v1/events/#{@event.id}", params: {
      access_token: access_token,
      event: {
        # 🚅 super scaffolding will also insert new fields above this line.
      }
    }

    assert_response :success

    # Ensure all the required data is returned properly.
    assert_proper_object_serialization response.parsed_body

    # But we have to manually assert the value was properly updated.
    @event.reload
    # 🚅 super scaffolding will additionally insert new fields above this line.

    # Also ensure we can't do that same action as another user.
    put "/api/v1/events/#{@event.id}", params: {access_token: another_access_token}
    assert_response :not_found
  end

  test "destroy" do
    # Delete and ensure it actually went away.
    assert_difference("Event.count", -1) do
      delete "/api/v1/events/#{@event.id}", params: {access_token: access_token}
      assert_response :success
    end

    # Also ensure we can't do that same action as another user.
    delete "/api/v1/events/#{@another_event.id}", params: {access_token: another_access_token}
    assert_response :not_found
  end
end
