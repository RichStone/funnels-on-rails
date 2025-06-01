class FunnelUserMailer < ApplicationMailer
  def welcome(user, funnel_name = nil)
    @user = user
    @funnel_name = funnel_name
    @cta_url = new_user_password_url
    @values = {
      funnel_name: @funnel_name || "our funnel",
      first_name: @user.first_name || "there"
    }
    mail(to: @user.email, subject: I18n.t("funnel_user_mailer.welcome.subject", **@values))
  end
end
