# make sure directory exists
directory '/srv/monkey_web' do
  action :create
end
# make sure file app.env exists
file '/srv/monkey_web/app.env' do
  content ''
  action :create
  only_if do ::Dir.exists?('/srv/monkey_web') end
end
# make sure file docker-compose.yml exists
file '/srv/monkey_web/docker-compose.yml' do
  content ''
  action :create
  only_if do ::Dir.exists?('/srv/monkey_web') end
end

# get app
app = search("aws_opsworks_app", "shortname:monkey_web").first

# create docker-compose file
file '/srv/monkey_web/docker-compose.yml' do
    content ::File.open('/srv/monkey_web/docker-compose-prod.yml').read
    action :nothing
    only_if do ::File.exists?('/srv/monkey_web/docker-compose-prod.yml') end
end

# populate app.env file
ruby_block "insert_line" do
  block do
    app['environment'].each do |env_var|
      file = Chef::Util::FileEdit.new("/srv/monkey_web/app.env")
      file.insert_line_if_no_match("/#{env_var[0]}=#{env_var[1]}/", "#{env_var[0]}=#{env_var[1]}")
      file.write_file
    end
  end
  action :nothing
end

# clone repository
application_git '/srv/monkey_web' do
  repository app['app_source']['url']
  revision app['app_source']['revision']
  deploy_key app['app_source']['ssh_key']
  notifies :create, 'file[/srv/monkey_web/docker-compose.yml]', :immediately
  notifies :create, 'ruby_block[insert_line]', :immediately
end
