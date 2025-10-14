class Avo::Resources::Event < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id
    field :agreement, as: :belongs_to
    field :creator, as: :belongs_to
    field :event_type, as: :text
    field :event_date_on, as: :date
    field :market_rate_amount, as: :number
  end
end
