# New Feature Rails Builders Community page

The Rails Builders Community page is a public page that shows all the Rails Builders participating in one of the Rails Builders accountability groups or development programs. Similar to this page:

https://www.funnelsonrails.com/rails-cooks-community

## Implementation

We will need to super scaffold with a team relation this new concept:

class RailsBuilder
first_name
last_name
email
builder_level
bio_image
details - a JSON column featuring these keys to start with: focusing_on, ai_setup, needs, offers, running_on, personal_quote, community_comment

We also need a model to represent participation in the group. members can start and leave many times, so there needs to be a has_many participations relation with fields like started_at, left_at, left_reason.

Team members can manage RailsBuilder records that have their own email address. Team admins can manage RailsBuilder records of with a matching email adress to any member of the team but not others.

The BuilderLevel is a separate global model not available for editing to team:
name
description
image

We should preseed the database with:
name: "Seeker" - "Someone trying to understand their place in the Rails space and maybe build a side project someday."
name: "Blueprint Apprentice" - "Our Apprentices follow blueprints to validate their idea and get to a first version of their MVP."
name: "Journeyman" - "The Journeyman has first real users and testers using their product"
name: "Foreman" - "The Foreman makes some revenue with their product"
name: "Architect" - "A visionary running a successful Rails business."
name: "Master Builder" - "The movers, trendsetters and biggest achievers of the industry."



## Super Scaffolding

For models that need scaffolding, use this documentation:

https://bullettrain.co/docs/super-scaffolding

Roles and abilities to show the correct RailsBuilders to team members and admins with Bullet Train are explained here:

- https://bullettrain.co/docs/teams
- https://bullettrain.co/docs/permissions