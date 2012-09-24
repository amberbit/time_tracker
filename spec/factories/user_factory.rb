Factory.sequence :email do |m|
  "testuser#{m}@amberbit.com"
end

Factory.define :user do |u|
    u.email               { Factory.next :email }
    u.password            "xxxxxxxxxxxxx"
    u.pivotal_tracker_api_token "111111111111111"
    u.admin               false
    u.confirmed_at        "#{Time.now}"
    u.employee_hourly_rate_ids []
    u.client_hourly_rate_ids   []
end

Factory.define :admin, :class => User do |u|
    u.email               "admin@amberbit.com"
    u.password            "xxxxxxxxxxxxx"
    u.pivotal_tracker_api_token "111111111111111"
    u.admin               true
    u.confirmed_at        "#{Time.now}"
    u.employee_hourly_rate_ids []
    u.client_hourly_rate_ids   []
end