
Via: https://claude.ai/chat/0dfbff29-48bd-4c15-aa52-9b353cbeacb3

# 1. Client model
rails generate super_scaffold Client Team \
  creator_id:super_select{class_name=Membership} \
  business_name:text_field \
  ein:text_field \
  property_address:text_area

# 2. Agreement model
rails generate super_scaffold Agreement Client \
  year:number_field \
  status:buttons \
  summary_details:text_area

# 3. Document model (assuming you want this as a child of Agreement)
rails generate super_scaffold Document Agreement \
  name:text_field \
  description:text_area

# 4. Event model
rails generate super_scaffold Event Agreement \
  event_type:super_select \
  event_date_on:date_field \
  market_rate_amount:number_field

# 5. EventInvitation model
rails generate super_scaffold EventInvitation Event \
  name:text_field \
  email:email_field \
  member_id:super_select{class_name=Membership}
