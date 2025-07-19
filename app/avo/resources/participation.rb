class Avo::Resources::Participation < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: params[:q], m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id
    field :rails_builder, as: :belongs_to
    field :started_at, as: :date_time
    field :left_at, as: :date_time
    field :left_reason, as: :textarea
  end
end
