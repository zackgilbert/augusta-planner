require "controllers/api/v1/test"

class Api::V1::AgreementsControllerTest < Api::Test
  setup do
    # See `test/controllers/api/test.rb` for common set up for API tests.

    @client = create(:client, team: @team)
    @agreement = build(:agreement, client: @client)
    @other_agreements = create_list(:agreement, 3)

    @another_agreement = create(:agreement, client: @client)

    # 🚅 super scaffolding will insert file-related logic above this line.
    @agreement.save
    @another_agreement.save

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
  def assert_proper_object_serialization(agreement_data)
    # Fetch the agreement in question and prepare to compare it's attributes.
    agreement = Agreement.find(agreement_data["id"])

    assert_equal_or_nil agreement_data["creator_id"], agreement.creator_id
    assert_equal_or_nil agreement_data["year"], agreement.year
    assert_equal_or_nil agreement_data["status"], agreement.status
    # 🚅 super scaffolding will insert new fields above this line.

    assert_equal agreement_data["client_id"], agreement.client_id
  end

  test "index" do
    # Fetch and ensure nothing is seriously broken.
    get "/api/v1/clients/#{@client.id}/agreements", params: {access_token: access_token}
    assert_response :success

    # Make sure it's returning our resources.
    agreement_ids_returned = response.parsed_body.map { |agreement| agreement["id"] }
    assert_includes(agreement_ids_returned, @agreement.id)

    # But not returning other people's resources.
    assert_not_includes(agreement_ids_returned, @other_agreements[0].id)

    # And that the object structure is correct.
    assert_proper_object_serialization response.parsed_body.first
  end

  test "show" do
    # Fetch and ensure nothing is seriously broken.
    get "/api/v1/agreements/#{@agreement.id}", params: {access_token: access_token}
    assert_response :success

    # Ensure all the required data is returned properly.
    assert_proper_object_serialization response.parsed_body

    # Also ensure we can't do that same action as another user.
    get "/api/v1/agreements/#{@agreement.id}", params: {access_token: another_access_token}
    assert_response :not_found
  end

  test "create" do
    # Use the serializer to generate a payload, but strip some attributes out.
    params = {access_token: access_token}
    agreement_data = JSON.parse(build(:agreement, client: nil).api_attributes.to_json)
    agreement_data.except!("id", "client_id", "created_at", "updated_at")
    params[:agreement] = agreement_data

    post "/api/v1/clients/#{@client.id}/agreements", params: params
    assert_response :success

    # # Ensure all the required data is returned properly.
    assert_proper_object_serialization response.parsed_body

    # Also ensure we can't do that same action as another user.
    post "/api/v1/clients/#{@client.id}/agreements",
      params: params.merge({access_token: another_access_token})
    assert_response :not_found
  end

  test "update" do
    # Post an attribute update ensure nothing is seriously broken.
    put "/api/v1/agreements/#{@agreement.id}", params: {
      access_token: access_token,
      agreement: {
        # 🚅 super scaffolding will also insert new fields above this line.
      }
    }

    assert_response :success

    # Ensure all the required data is returned properly.
    assert_proper_object_serialization response.parsed_body

    # But we have to manually assert the value was properly updated.
    @agreement.reload
    # 🚅 super scaffolding will additionally insert new fields above this line.

    # Also ensure we can't do that same action as another user.
    put "/api/v1/agreements/#{@agreement.id}", params: {access_token: another_access_token}
    assert_response :not_found
  end

  test "destroy" do
    # Delete and ensure it actually went away.
    assert_difference("Agreement.count", -1) do
      delete "/api/v1/agreements/#{@agreement.id}", params: {access_token: access_token}
      assert_response :success
    end

    # Also ensure we can't do that same action as another user.
    delete "/api/v1/agreements/#{@another_agreement.id}", params: {access_token: another_access_token}
    assert_response :not_found
  end
end
