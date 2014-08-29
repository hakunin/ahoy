Warden::Manager.after_set_user except: :fetch do |user, auth, opts|
  return if user.is_a? AdminUser
  request = ActionDispatch::Request.new(auth.env)
  ahoy = Ahoy::Tracker.new(request: request)
  ahoy.authenticate(user)
end
