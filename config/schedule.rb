every 10.minutes do
  runner 'User.each do |user|
    Task.download_for_user(user)
  end'
end
