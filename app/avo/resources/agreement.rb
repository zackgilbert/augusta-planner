class Avo::Resources::Agreement < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id
    field :client, as: :belongs_to
    field :creator, as: :belongs_to
    field :year, as: :number
    field :status, as: :text
  end
end
