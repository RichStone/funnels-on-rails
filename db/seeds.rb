# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# 👋 Also, seeds in Bullet Train are slightly different than vanilla Rails.
# See `docs/seeds.md` for details.

puts "🌱 Generating global seeds."

# Seed Builder Levels
puts "Creating Builder Levels..."
[
  {
    name: "Seeker",
    description: "Someone trying to understand their place in the Rails space and maybe build a side project someday.",
    image: nil  # No image provided for Seeker
  },
  {
    name: "Blueprint Apprentice",
    description: "Our Apprentices follow blueprints to validate their idea and get to a first version of their MVP.",
    image: "builder_levels/blueprint-apprentice.png"
  },
  {
    name: "Journeyman",
    description: "The Journeyman has first real users and testers using their product and learning to get the next steps in the journey.",
    image: "builder_levels/journeyman.png"
  },
  {
    name: "Foreman",
    description: "The Foreman has revenue with their product and looking to scale.",
    image: "builder_levels/foreman.png"
  },
  {
    name: "Architect",
    description: "A visionary running a successful Rails business.",
    image: "builder_levels/architect.png"
  },
  {
    name: "Master Builder",
    description: "The movers, trendsetters and biggest achievers of the industry.",
    image: "builder_levels/master-builder.png"
  }
].each do |level_data|
  level = BuilderLevel.find_or_create_by(name: level_data[:name]) do |l|
    l.description = level_data[:description]
  end
  
  # Update image path if provided
  if level_data[:image]
    level.update(image: level_data[:image])
  end
end
puts "Created #{BuilderLevel.count} Builder Levels."

# Check whether the Zapier app has been deployed.
zapier_app_id = begin
  JSON.parse(File.read("zapier/.zapierapprc")).dig("id")
rescue
  nil
end

# If it has, configure a platform application for Zapier in this environment.
if zapier_app_id
  creating = false
  zapier = Platform::Application.find_or_create_by(name: "Zapier", team: nil) do |zapier|
    creating = true
  end

  puts ""
  puts "Creating a platform application for Zapier. Within the `zapier` directory, run:".yellow
  puts ""
  puts "  cd zapier".yellow
  puts "  zapier env:set 1.0.0 BASE_URL=#{ENV["BASE_URL"]} CLIENT_ID=#{zapier.uid} CLIENT_SECRET=#{zapier.secret}".yellow
  puts "  cd ..".yellow
  puts ""

  zapier.redirect_uri = "https://zapier.com/dashboard/auth/oauth/return/App#{zapier_app_id}CLIAPI/"
  zapier.save
end

load "#{Rails.root}/db/seeds/development.rb" if Rails.env.development?
load "#{Rails.root}/db/seeds/test.rb" if Rails.env.test?
load "#{Rails.root}/db/seeds/production.rb" if Rails.env.production?
