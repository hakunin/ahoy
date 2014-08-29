Warden::Manager.after_set_user except: :fetch do |user, auth, opts|
  request = ActionDispatch::Request.new(auth.env)
  unless user.is_a? AdminUser
    ahoy = Ahoy::Tracker.new(request: request)
    ahoy.authenticate(user)
  end
end
