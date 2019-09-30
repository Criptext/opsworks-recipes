
#setup cron jobs
cron 'delete_blacklisted_events' do
    action :create
    minute '00'
    hour '13'
    weekday '1'
    user 'ec2-user'
    mailto "jose@criptext.com,daniel@criptext.com"
    environment app['environment']
    command "/usr/bin/node /srv/#{node['app']}/scripts/src/purge-blacklisted-events.js"
  end
  
  cron 'delete_blacklisted_emails' do
    action :create
    minute '00'
    hour '13'
    weekday '1'
    user 'ec2-user'
    mailto "jose@criptext.com,daniel@criptext.com"
    environment app['environment']
    command "/usr/bin/node /srv/#{node['app']}/scripts/src/purge-blacklisted-emails.js"
  end