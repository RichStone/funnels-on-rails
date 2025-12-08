# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Salutation

Whenever talking to me directly or spinning up Claude Code you need to salute me with Chief Creation Officer (or Chief when you need to keep it short).

## Development Workflow

The instructions here apply to most small and big changes. For experts and subagents, use the files in `.claude/agents`.

### Plan

If you were not explicitly told to create a PLAN.md, prefer to suggest a bullet list of changes you want to make before actually making the changes.

When creating a PLAN.md you must take into consideration all of these aspects:

- Problem
- Solution
- Implementation
- automated testing, i.e., which tests need writing and updating and which you will run to verify the implementation
- archictural consistency
- QA testing (AKA Testing Notes)
- prefer not to write code or pseudo code at this stage

### Git

- Create atomic commits for the different steps that you work off. Atomic commits doesn't mean small commits. They can be bigger commits with everything that belongs together to achieve the goal of the commit.
- Keep your commit messages very short, concise and to the point, no need to write bullet points and paragraphs if you've added a test, just state in the title what you did.
- Use format: "[Action present tense][Subject][Purpose]". For example, "Add dashboard for improved user insights".
- For smaller commits, prefer just having a title.
- For more important commits, you may have more information in the message body.

### GitHub

- Always use the `gh` CLI tool when interacting with GitHub as we are working on a private repo here.
- Never push to GitHub unless I ask you to.
- NEVER EVER force push anything to github, this is a right reserved to Master Foo only.
- NEVER EVER amend anything, always create new git commits if you need to commit something.

### Testing

- To run tests always use this format: `rails test test/controllers/api/v1/`
- For more targeted testing, consider running just one file: `rails test/controllers/api/v1/businesses_controller_test.rb`
- Use Minitest best practices, keeping tests simple, not fear some duplication to make things clear, but don't have too much test granularity, for example, don't have separate test cases to just assert for different attributes.
- In the `test "does something specific with a specific result"` always start with a verb to describe what the test subject does and always be clear about what the expectation for that test case and test subjectd is.
- When writing system tests, avoid asserting for text content that are part of html structure, rather focus on important values and data values appearing from the test setup where possible

### Formatting

- After all implementation is done, you MUST ALWAYS run `bundle exec standardrb --fix` to fix formatting issues otherwise we won't be able to commit the changes and your work won't be accepted.

### Comments

- Use comments very sparengly, only if you know the why behind a technical decision you may add a comment.
- Just explaining what the code does is a no-go.

### Completion

- When completing tasks or plans, run `say "[Task|Plan] completed, Chief"` or sometimes `say "[Task|Plan] completed, Chief Creation Officer"` at the end to provide an audible notification.

### Deployment

Never ever touch or run any deployment or Kamal commands.

## Project Overview
This is a Ruby on Rails 8.0 application built on the Bullet Train framework. It integrates with ClickFunnels for user management and power user tracking.

## Development Commands

### Setup
```bash
bin/setup                    # Initial setup (installs dependencies, creates database)
bin/rails db:seed           # Seed database with sample data
```

### Running the Application
```bash
bin/dev                     # Start development server with Procfile.dev (includes Sidekiq, CSS/JS watching)
bin/rails server            # Start only Rails server
```

### Testing
```bash
bin/rails test              # Run all tests
bin/rails test test/path/to/specific_test.rb  # Run specific test file
bin/rails test test/path/to/test.rb:42        # Run specific test at line 42
MAGIC_TEST=1 bin/rails test:system             # Record system tests with Magic Test
```

### Code Quality
```bash
bundle exec standardrb      # Run Ruby linter
bundle exec standardrb --fix # Auto-fix Ruby linting issues
```

### Database
```bash
bin/rails db:migrate        # Run pending migrations
bin/rails db:rollback       # Rollback last migration
bin/rails db:schema:dump    # Update db/schema.rb
```

### Background Jobs
```bash
bundle exec sidekiq         # Run Sidekiq (included in bin/dev)
```

### Deployment
```bash
bin/kamal deploy            # Deploy to production using Kamal
```

## Architecture Overview

### Bullet Train Framework
Bullet Train is a comprehensive Ruby on Rails SaaS framework that provides extensive built-in functionality. This application leverages:

**Core Features**:
- Multi-tenancy with Teams and membership-based permissions
- User authentication with Devise
- OAuth integration via Doorkeeper
- Webhook handling (incoming and outgoing)
- Admin panel via Avo
- API versioning structure
- Role-based access control with granular permissions
- Onboarding workflows
- Billing system integration (Stripe)
- Zapier integration support

**Super Scaffolding**:
Bullet Train's code generation engine that creates complete CRUD interfaces. Key commands:

```bash
# Generate new model with CRUD interface
rails generate super_scaffold ModelName Team field:field_type

# Add field to existing model
rails generate super_scaffold:field ModelName field:field_type

# Available field types: text_field, trix_editor, buttons, super_select, image
```

Use the docs to get detailed info about how to scaffold:
https://bullettrain.co/docs/super-scaffolding

Example:
```bash
# Create a Project model under Team
rails generate super_scaffold Project Team name:text_field description:trix_editor
rake db:migrate

# Add status field with button options
rails generate super_scaffold:field Project status:buttons
rake db:migrate
```

**Important Conventions**:
- All models are typically scoped to Teams
- Keep magic comments in generated files for future scaffolding
- Use `valid_*` methods for defining select field options
- Support for Action Models for complex business logic
- Modular design allows overriding framework components

### Key Components

**ClickFunnels Integration** (app/lib/clickfunnels/):
- Custom Faraday-based client for ClickFunnels API
- Plans to migrate to official clickfunnels-ruby-sdk gem (see PLAN.md)
- Webhook handling for ClickFunnels events
- Background job for marking power users

**API Structure** (app/controllers/api/v1/):
- RESTful API with versioning
- OAuth authentication via Doorkeeper
- Standard JSON responses

**Webhook System** (app/controllers/webhooks/):
- Incoming webhooks from external services
- Outgoing webhooks for event notifications
- Signature verification for security

**Background Processing**:
- Sidekiq for async job processing
- Redis for job queue storage
- MarkPowerUserJob for ClickFunnels integration

### Configuration

**Environment Variables** (config/application.yml):
- BASE_URL: Application base URL
- MARKETING_SITE_URL: Marketing site URL
- STRIPE_SECRET_KEY: Stripe API key
- CLICK_FUNNELS_API_KEY: ClickFunnels API key
- CLICK_FUNNELS_WORKSPACE_SUBDOMAIN: ClickFunnels subdomain (to be renamed)
- CLICK_FUNNELS_WORKSPACE_ID: Workspace ID (to be moved to config)

**Database**: PostgreSQL with ActiveRecord

**Asset Pipeline**: 
- ESBuild for JavaScript bundling
- Tailwind CSS with PostCSS
- Stimulus for JavaScript framework

### Testing Strategy
- Minitest for unit and integration tests
- Capybara for system tests
- FactoryBot for test data
- SimpleCov for coverage reporting
- Fixtures for external API responses (test/fixtures/clickfunnels/)
- For factories, don't use dummy values but something close to real. For example, do it like this:
```ruby
FactoryBot.define do
  factory :business do
    association :team
    name { "Funnels on Rails" }
    description { "Funnels on Rails connects the engineering and business dots for technical founders. 🚀" }
  end
end
```

/file:.claude-on-rails/context.md
