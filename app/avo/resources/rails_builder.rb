class Avo::Resources::RailsBuilder < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: params[:q], m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id
    field :team, as: :belongs_to
    field :first_name, as: :text
    field :last_name, as: :text
    field :email, as: :text
    field :builder_level, as: :belongs_to
    field :bio_image, as: :text
  end
end
