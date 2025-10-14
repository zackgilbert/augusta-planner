
Via: https://claude.ai/chat/0dfbff29-48bd-4c15-aa52-9b353cbeacb3

# 1. Client - 2025-10-14
rails generate super_scaffold Client Team \
  creator_id:super_select{class_name=Membership} \
  business_name:text_field \
  ein:text_field

# 2. Agreement - 2025-10-14
rails generate super_scaffold Agreement Client,Team \
  creator_id:super_select{class_name=Membership} \
  year:number_field \
  status:super_select \
  property_address:text_area

# 3. Event - 2025-10-14
rails generate super_scaffold Event Agreement,Client,Team \
  creator_id:super_select{class_name=Membership} \
  event_type:super_select \
  event_date_on:date_field \
  market_rate_amount:number_field

# 4. EventInvitation
rails generate super_scaffold EventInvitation Event,Agreement,Client,Team \
  creator_id:super_select{class_name=Membership} \
  name:text_field \
  email:email_field
