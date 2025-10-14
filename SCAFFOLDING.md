
Via: https://claude.ai/chat/0dfbff29-48bd-4c15-aa52-9b353cbeacb3

# 1. Client - 2025-10-14
rails generate super_scaffold Client Team \
  creator_id:super_select{class_name=Membership} \
  business_name:text_field \
  ein:text_field \
  property_address:text_area

# 2. Agreement - 2025-10-14
rails generate super_scaffold Agreement Client,Team \
  creator_id:super_select{class_name=Membership} \
  year:number_field \
  status:super_select

# 3. Event model
rails generate super_scaffold Event Agreement,Client,Team \
  creator_id:super_select{class_name=Membership} \
  event_type:super_select \
  event_date_on:date_field \
  market_rate_amount:number_field

# 4. EventInvitation model
rails generate super_scaffold EventInvitation Event \
  name:text_field \
  email:email_field \
  member_id:super_select{class_name=Membership}

# 5. Document - (Punting for now until we figure out what exactly we want)
rails generate super_scaffold Document Agreement,Client,Team \
  name:text_field \
  description:text_area
