set :user, "#{application}-#{stage}"
set :group, "#{application}-#{stage}"
set :deploy_env, 'staging'
set :deploy_to, "/home/#{user}/app"
