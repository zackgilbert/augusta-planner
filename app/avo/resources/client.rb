class Avo::Resources::Client < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }
  
  def fields
    field :id, as: :id
    field :team, as: :belongs_to
    field :creator, as: :belongs_to
    field :business_name, as: :text
    field :ein, as: :text
  end
end
