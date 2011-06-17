set :user, "#{application}-#{stage}"
set :group, "#{application}-#{stage}"
set :deploy_env, 'production'
set :deploy_to, "/home/#{user}/app"
