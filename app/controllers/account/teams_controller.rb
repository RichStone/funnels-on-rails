class Account::TeamsController < Account::ApplicationController
  include Account::Teams::ControllerBase

  # Override the show action to add random tips
  def show
    super
    # Read files and choose random entries
    dev_tips_path = Rails.root.join('public', 'devmarketingtips.txt')
    rails_reasons_path = Rails.root.join('public', 'railsisdeadreasons.txt')
    
    dev_tips = File.exist?(dev_tips_path) ? File.readlines(dev_tips_path).map(&:strip).reject(&:empty?) : []
    rails_reasons = File.exist?(rails_reasons_path) ? File.readlines(rails_reasons_path).map(&:strip).reject(&:empty?) : []
    
    @random_tip = dev_tips.sample if dev_tips.any?
    @random_reason = rails_reasons.sample if rails_reasons.any?
    render Views::Account::Teams::Show.new
  end

  private

  def permitted_fields
    [
      # 🚅 super scaffolding will insert new fields above this line.
    ]
  end

  def permitted_arrays
    {
      # 🚅 super scaffolding will insert new arrays above this line.
    }
  end

  def process_params(strong_params)
    # 🚅 super scaffolding will insert processing for new fields above this line.
    strong_params
  end
end
