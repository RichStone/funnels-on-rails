# Preview all emails at http://localhost:3000/rails/mailers/funnel_user_mailer
class FunnelUserMailerPreview < ActionMailer::Preview
  def welcome
    user = User.first || FactoryBot.build(:user)
    funnel_name = "Landing Page Funnel"
    FunnelUserMailer.welcome(user, funnel_name)
  end
end
