json.extract! rails_builder,
  :id,
  :team_id,
  :first_name,
  :last_name,
  :email,
  :builder_level_id,
  # 🚅 super scaffolding will insert new fields above this line.
  :created_at,
  :updated_at

if rails_builder.bio_image.attached?
  json.bio_image do
    json.url url_for(rails_builder.bio_image)
  end
else
  json.bio_image nil
end
# 🚅 super scaffolding will insert file-related logic above this line.
