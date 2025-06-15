Warden::Manager.after_authentication do |user, auth, options|
  Current.user = user

  # Mark user as power user in ClickFunnels if this is their second login
  if user.sign_in_count == 2
    MarkPowerUserJob.perform_later(user.email)
  end
end

Warden::Manager.before_logout do |user, auth, options|
  Current.user = nil
end
