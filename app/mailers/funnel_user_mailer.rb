class FunnelUserMailer < ApplicationMailer
  def welcome(user, funnel_name = nil)
    @user = user
    @funnel_name = funnel_name
    @cta_url = edit_password_url(user, reset_password_token: @user.send(:set_reset_password_token))
    @values = {
      funnel_name: @funnel_name || "our funnel",
      first_name: @user.first_name || "there"
    }
    mail(to: @user.email, subject: I18n.t("funnel_user_mailer.welcome.subject", **@values))
  end
end
