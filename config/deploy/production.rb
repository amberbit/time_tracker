set :user, "#{application}-#{stage}"
set :group, "#{application}-#{stage}"
set :deploy_env, 'production'
set :deploy_to, "/home/#{user}/app"
set :branch, 'v1.3.0'
