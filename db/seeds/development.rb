puts "🌱 Generating development environment seeds."

# Create a default team to associate Rails Builders with
default_team = Team.first || begin
  user = User.create!(
    email: "admin@example.com",
    password: "password123",
    password_confirmation: "password123",
    first_name: "Admin",
    last_name: "User"
  )
  user.create_default_team
  user.teams.first
end

puts "Creating Rails Builders with participations..."

# Get builder levels
seeker = BuilderLevel.find_by(name: "Seeker")
apprentice = BuilderLevel.find_by(name: "Blueprint Apprentice")
journeyman = BuilderLevel.find_by(name: "Journeyman")
foreman = BuilderLevel.find_by(name: "Foreman")
architect = BuilderLevel.find_by(name: "Architect")
master_builder = BuilderLevel.find_by(name: "Master Builder")

# Rails Builder 1: Currently active, joined 6 months ago
builder1 = RailsBuilder.find_or_create_by(email: "sarah.johnson@example.com") do |rb|
  rb.team = default_team
  rb.first_name = "Sarah"
  rb.last_name = "Johnson"
  rb.builder_level = journeyman
  rb.details = {
    focusing_on: "Building a SaaS for project management",
    ai_setup: "GitHub Copilot and ChatGPT",
    needs: "Help with scaling and performance optimization",
    offers: "Experience with payment integrations and Stripe",
    running_on: "Heroku with PostgreSQL",
    personal_quote: "Rails makes me feel like a superhero developer!",
    community_comment: "Love the supportive community here"
  }
end
builder1.participations.create!(started_at: 6.months.ago)
unless builder1.bio_image.attached?
  builder1.bio_image.attach(
    io: File.open(Rails.root.join("app/assets/images/rails_builders/rob.png")),
    filename: "rob.png",
    content_type: "image/png"
  )
end

# Rails Builder 2: Left and rejoined
builder2 = RailsBuilder.find_or_create_by(email: "mike.chen@example.com") do |rb|
  rb.team = default_team
  rb.first_name = "Mike"
  rb.last_name = "Chen"
  rb.builder_level = foreman
  rb.details = {
    focusing_on: "E-commerce platform for local businesses",
    ai_setup: "Cursor AI and Claude",
    needs: "Marketing advice and user acquisition strategies",
    offers: "Expert knowledge in Rails performance tuning",
    running_on: "AWS EC2 with Docker",
    personal_quote: "Building dreams one commit at a time",
    community_comment: "This group helped me go from idea to revenue!"
  }
end
# First participation (left after 3 months)
builder2.participations.create!(
  started_at: 1.year.ago,
  left_at: 9.months.ago,
  left_reason: "Took a break to focus on a full-time job"
)
# Rejoined 2 months ago
builder2.participations.create!(started_at: 2.months.ago)
unless builder2.bio_image.attached?
  builder2.bio_image.attach(
    io: File.open(Rails.root.join("app/assets/images/rails_builders/rob.png")),
    filename: "rob.png",
    content_type: "image/png"
  )
end

# Rails Builder 3: New member
builder3 = RailsBuilder.find_or_create_by(email: "emily.rodriguez@example.com") do |rb|
  rb.team = default_team
  rb.first_name = "Emily"
  rb.last_name = "Rodriguez"
  rb.builder_level = seeker
  rb.details = {
    focusing_on: "Learning Rails and building my first app",
    ai_setup: "Just started with GitHub Copilot",
    needs: "Mentorship and code reviews",
    offers: "Fresh perspective and enthusiasm",
    running_on: "Local development for now",
    personal_quote: "Every expert was once a beginner",
    community_comment: "Excited to be part of this journey!"
  }
end
builder3.participations.create!(started_at: 2.weeks.ago)
unless builder3.bio_image.attached?
  builder3.bio_image.attach(
    io: File.open(Rails.root.join("app/assets/images/rails_builders/rob.png")),
    filename: "rob.png",
    content_type: "image/png"
  )
end

# Rails Builder 4: Long-time member who left
builder4 = RailsBuilder.find_or_create_by(email: "david.kim@example.com") do |rb|
  rb.team = default_team
  rb.first_name = "David"
  rb.last_name = "Kim"
  rb.builder_level = architect
  rb.details = {
    focusing_on: "Building a Rails consultancy",
    ai_setup: "Custom AI tools integrated with Rails",
    needs: "Finding talented Rails developers",
    offers: "Architectural guidance and code reviews",
    running_on: "Kubernetes cluster on GCP",
    personal_quote: "Rails scales beautifully when done right",
    community_comment: "Grateful for all the connections made here"
  }
end
builder4.participations.create!(
  started_at: 2.years.ago,
  left_at: 1.month.ago,
  left_reason: "Focusing on growing the consultancy business"
)
unless builder4.bio_image.attached?
  builder4.bio_image.attach(
    io: File.open(Rails.root.join("app/assets/images/rails_builders/rob.png")),
    filename: "rob.png",
    content_type: "image/png"
  )
end

# Rails Builder 5: Active member progressing through levels
builder5 = RailsBuilder.find_or_create_by(email: "alex.thompson@example.com") do |rb|
  rb.team = default_team
  rb.first_name = "Alex"
  rb.last_name = "Thompson"
  rb.builder_level = apprentice
  rb.details = {
    focusing_on: "MVP for a fitness tracking app",
    ai_setup: "VS Code with GitHub Copilot",
    needs: "UI/UX design advice and user testing",
    offers: "Background in mobile app development",
    running_on: "Render.com",
    personal_quote: "From mobile to Rails, loving the transition!",
    community_comment: "The accountability really keeps me going"
  }
end
builder5.participations.create!(started_at: 4.months.ago)
unless builder5.bio_image.attached?
  builder5.bio_image.attach(
    io: File.open(Rails.root.join("app/assets/images/rails_builders/rob.png")),
    filename: "rob.png",
    content_type: "image/png"
  )
end

# Rails Builder 6: Master Builder - highly successful
builder6 = RailsBuilder.find_or_create_by(email: "jennifer.wu@example.com") do |rb|
  rb.team = default_team
  rb.first_name = "Jennifer"
  rb.last_name = "Wu"
  rb.builder_level = master_builder
  rb.details = {
    focusing_on: "Running a successful Rails agency with 20+ developers",
    ai_setup: "Custom AI toolchain integrated across the entire team",
    needs: "Strategic partnerships and enterprise clients",
    offers: "Mentorship, investment opportunities, and technical guidance",
    running_on: "Multi-region AWS infrastructure with full CI/CD",
    personal_quote: "Rails allowed me to build an empire, one line at a time",
    community_comment: "Giving back to the community that gave me everything"
  }
end
builder6.participations.create!(started_at: 3.years.ago)
unless builder6.bio_image.attached?
  builder6.bio_image.attach(
    io: File.open(Rails.root.join("app/assets/images/rails_builders/rob.png")),
    filename: "rob.png",
    content_type: "image/png"
  )
end

puts "Created #{RailsBuilder.count} Rails Builders with #{Participation.count} participations"
puts "  - Active builders: #{RailsBuilder.joins(:participations).where(participations: { left_at: nil }).distinct.count}"
puts "  - Inactive builders: #{RailsBuilder.joins(:participations).where.not(participations: { left_at: nil }).where.not(id: RailsBuilder.joins(:participations).where(participations: { left_at: nil })).distinct.count}"
