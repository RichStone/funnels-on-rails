# Funnels on Rails Tutorial Plan

## Overview

This tutorial teaches Rails developers how to build customer-centric SaaS applications by combining the Bullet Train framework with ClickFunnels' marketing automation. The content is structured into funnel pages (minimal, action-focused), learn more pages (educational content), and technical tutorials (implementation guides).

## Part 1: Funnel Step Pages (Simplified)

### Step 1: Landing Page (/)
**Keep it Simple - Focus on the Problem**
```
Headline: Funnels on Rails - Your Developer Product Marketing Tutorial
Subheadline: Stop Building Products Nobody and Learn to build your Rails SaaS with customers in mind first

[Get Started Free →]
```

### Step 2: Free Sign-Up (/free-sign-up)
**Single Clear Action**
```
Headline: Get Your Customer-First Rails Starter Kit
Subheadline: Everything you need to build a SaaS that actually sells

[Email Field]
[Get Instant Access]

✓ Bullet Train framework pre-configured
✓ ClickFunnels integration ready
✓ Customer analytics built-in
```

### Step 3: Premium Upsell (/audacious-upsell)
**Make the Value Clear**
```
Headline: Go Premium for $1/month
Subheadline: Get direct access to implementation support

What You Get:
✓ Monthly office hours with Rich
✓ Priority support in Discord
✓ Advanced tutorial content
✓ Real-world case studies

[Yes, Upgrade Me! →]
[Maybe Later]
```

### Step 4: Thank You (/thank-you)
**Deliver Immediate Value**
```
Headline: Welcome to the Customer-First Rails Community!

Your Next Steps:
1. Check your email for login credentials
2. Join our Discord community
3. Start with Tutorial #1 below

[Access Your Dashboard →]
```

## Part 2: Learn More Pages (Educational Content)

### /learn/funnel-fundamentals
**Title: Sales Funnels 101 for Developers**

1. **What is a Sales Funnel?**
   - Customer journey mapping
   - Why linear paths convert better
   - Funnel vs. traditional website

2. **The Psychology Behind Funnels**
   - Decision fatigue
   - Progressive commitment
   - Value ladders

3. **Essential Funnel Components**
   - Landing pages
   - Lead magnets
   - Tripwires
   - Core offers
   - Profit maximizers

### /learn/customer-first-development
**Title: Building Products People Actually Want**

1. **The Problem with Feature-First Development**
   - Why most SaaS products fail
   - The build trap
   - Feature bloat

2. **Customer Development Process**
   - Problem discovery techniques
   - Solution validation
   - MVP strategies

3. **Metrics That Matter**
   - Customer acquisition cost (CAC)
   - Lifetime value (LTV)
   - Churn rate
   - Net promoter score (NPS)

### /learn/marketing-automation-basics
**Title: Automating Your Customer Journey**

1. **Email Marketing Fundamentals**
   - Welcome sequences
   - Nurture campaigns
   - Segmentation strategies

2. **Behavioral Triggers**
   - Event-based automation
   - Lead scoring
   - Tag-based workflows

3. **Integration Patterns**
   - Webhook orchestration
   - API synchronization
   - Data consistency

### /learn/business-operating-systems
**Title: Beyond Code: Running Your SaaS Business**

1. **What is a Business Operating System?**
   - ClickFunnels as your command center
   - Separating business logic from code
   - Configuration over customization

2. **Core Business Functions**
   - Customer management
   - Payment processing
   - Analytics and reporting

3. **Scaling Without Complexity**
   - When to build vs. buy
   - Integration-first architecture
   - Maintaining simplicity

## Part 3: Technical Tutorials (Implementation Guides)

### /tutorials/bullet-train-quickstart
**Title: Setting Up Your Rails SaaS in 10 Minutes**

```ruby
# 1. Clone the repository
git clone https://github.com/yourusername/funnels-on-rails.git
cd funnels-on-rails

# 2. Install dependencies
bundle install
yarn install

# 3. Setup database
bin/rails db:create db:migrate db:seed

# 4. Configure environment
cp config/application.yml.example config/application.yml
# Edit with your API keys

# 5. Start the server
bin/dev
```

**Key Files to Understand:**
- `config/application.yml` - Environment configuration
- `app/models/user.rb` - User model with subscription status
- `app/controllers/account/teams_controller.rb` - Team dashboard

### /tutorials/clickfunnels-integration
**Title: Connecting ClickFunnels to Your Rails App**

**1. Webhook Setup**
```ruby
# app/controllers/webhooks/incoming/click_funnels_webhooks_controller.rb
class Webhooks::Incoming::ClickFunnelsWebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token
  
  def create
    webhook = Webhooks::Incoming::ClickFunnelsWebhook.create!(data: params)
    webhook.process_async
    head :ok
  end
  
  private
  
  def verify_signature
    # Implement signature verification
  end
end
```

**2. Event Processing**
```ruby
# app/models/webhooks/incoming/click_funnels_webhook.rb
def process
  case event_type
  when "form_submission.created"
    create_user_account
  when "subscription.invoice.paid"
    upgrade_to_premium
  end
end
```

**3. Using the ClickFunnels Client**
```ruby
# app/clients/click_funnels.rb
client = ClickFunnels.new
contact = client.find_contact_by_email("user@example.com")
client.mark_as_power_user("user@example.com")
```

### /tutorials/user-lifecycle-automation
**Title: Automating User Onboarding and Retention**

**1. Welcome Email Sequence**
```ruby
# app/mailers/funnel_user_mailer.rb
class FunnelUserMailer < ApplicationMailer
  def welcome(user, funnel_name)
    @user = user
    @funnel_name = funnel_name
    mail(to: user.email, subject: "Welcome to Funnels on Rails!")
  end
end
```

**2. Power User Identification**
```ruby
# app/jobs/mark_power_user_job.rb
class MarkPowerUserJob < ApplicationJob
  def perform(email)
    client = ClickFunnels.new
    client.mark_as_power_user(email)
  end
end
```

**3. Subscription Management**
```ruby
# app/models/user.rb
class User < ApplicationRecord
  SUBSCRIPTION_STATUSES = {
    free: "free",
    premium: "premium"
  }
  
  def premium?
    subscription_status == SUBSCRIPTION_STATUSES[:premium]
  end
end
```

### /tutorials/local-development-setup
**Title: Setting Up Webhooks for Local Development**

**1. Using ngrok for Local Webhooks**
```bash
# bin/ngrok-with-webhook
#!/usr/bin/env bash
set -e

echo "Starting ngrok..."
ngrok http 3000 > /tmp/ngrok.log &

sleep 2
NGROK_URL=$(curl -s localhost:4040/api/tunnels | jq -r '.tunnels[0].public_url')

echo "Updating webhook URL to: $NGROK_URL"
bin/update-webhook-url $NGROK_URL
```

**2. Webhook Testing**
```ruby
# test/controllers/webhooks/incoming/click_funnels_webhooks_controller_test.rb
test "should create user from form submission" do
  payload = JSON.parse(file_fixture("click_funnels/form_submission_payload.json").read)
  
  assert_difference "User.count", 1 do
    post webhooks_incoming_click_funnels_webhooks_path, params: payload
  end
  
  assert_response :success
end
```

### /tutorials/deployment-with-kamal
**Title: Deploying Your Rails Funnel App**

**1. Kamal Configuration**
```yaml
# config/deploy.yml
service: funnels-on-rails
image: yourusername/funnels-on-rails

servers:
  - your-server-ip

env:
  clear:
    RAILS_SERVE_STATIC_FILES: true
  secret:
    - RAILS_MASTER_KEY
    - CLICK_FUNNELS_API_KEY
```

**2. Deployment Commands**
```bash
# Initial setup
kamal setup

# Deploy updates
kamal deploy

# View logs
kamal app logs -f
```

### /tutorials/testing-strategies
**Title: Testing Your Funnel Integration**

**1. Unit Testing the ClickFunnels Client**
```ruby
# test/clients/click_funnels_test.rb
class ClickFunnelsTest < ActiveSupport::TestCase
  test "finds contact by email" do
    VCR.use_cassette("click_funnels/find_contact") do
      client = ClickFunnels.new
      contact = client.find_contact_by_email("test@example.com")
      assert_equal "test@example.com", contact["email_address"]
    end
  end
end
```

**2. System Testing the User Journey**
```ruby
# test/system/user_signup_flow_test.rb
test "user can sign up through funnel" do
  visit root_path
  click_link "Get Started Free"
  
  fill_in "Email", with: "new@example.com"
  click_button "Get Instant Access"
  
  assert_text "Welcome to the Customer-First Rails Community!"
  assert User.exists?(email: "new@example.com")
end
```

## Part 4: Advanced Topics

### /tutorials/custom-funnel-analytics
**Title: Building Custom Analytics for Your Funnel**

- Tracking conversion rates
- Cohort analysis
- A/B testing implementation
- Integration with analytics services

### /tutorials/multi-tenant-funnels
**Title: Creating Funnels for Multi-Tenant SaaS**

- Team-based funnel customization
- White-label funnel pages
- Dynamic pricing based on team size
- Affiliate tracking

### /tutorials/webhook-orchestration
**Title: Advanced Webhook Patterns**

- Webhook retry logic
- Event deduplication
- Webhook security best practices
- Debugging webhook issues

## Implementation Timeline

### Phase 1: Core Content (Week 1)
- [ ] Implement simplified funnel pages
- [ ] Create funnel fundamentals learn page
- [ ] Write Bullet Train quickstart tutorial

### Phase 2: Technical Depth (Week 2)
- [ ] Create remaining learn pages
- [ ] Write ClickFunnels integration tutorial
- [ ] Add user lifecycle automation tutorial

### Phase 3: Advanced Content (Week 3)
- [ ] Add deployment tutorial
- [ ] Create testing strategies guide
- [ ] Write advanced topics tutorials

### Phase 4: Polish & Launch (Week 4)
- [ ] Add code examples to all tutorials
- [ ] Create video walkthroughs for complex topics
- [ ] Set up tutorial navigation system
- [ ] Launch and gather feedback

## Success Metrics

1. **Engagement Metrics**
   - Tutorial completion rate > 60%
   - Average time on tutorial pages > 5 minutes
   - Return visitor rate > 40%

2. **Conversion Metrics**
   - Free sign-up conversion > 25%
   - Free to premium conversion > 5%
   - Tutorial to implementation rate > 30%

3. **Community Metrics**
   - Discord community growth
   - GitHub stars and forks
   - User-generated content

## Notes for Implementation

- Keep funnel pages under 150 words
- Include runnable code examples in all technical tutorials
- Add "Try it Yourself" sections with sandboxed environments
- Create companion videos for complex tutorials
- Build an interactive progress tracker for users
- Consider gamification elements (badges, certificates)