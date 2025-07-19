# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

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

/file:.claude-on-rails/context.md
