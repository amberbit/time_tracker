every 10.minutes do
  runner 'User.all.each { |user| Task.download_for_user(user) }'
end
