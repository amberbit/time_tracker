every 10.minutes do
  runner 'User.each { |user| Task.download_for_user(user) }'
end
