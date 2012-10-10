every 10.minutes do
  User.each do |user|
    Task.download_for_user(user)
  end
end