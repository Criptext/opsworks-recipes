
# clone repository
app = search("aws_opsworks_app", "shortname:monkey_web").first
application_git '/srv/monkey_web' do
  repository 'git@github.com:Criptext/Monkey-Web-API.git'
  deploy_key app['app_source']['ssh_key']
end

# make sure file app.env exists
file '/srv/monkey_web/app.env' do
  action :create_if_missing
end

# create docker-compose file if it doesn't exist
file '/srv/monkey_web/docker-compose.yml' do
  content IO.read('/srv/monkey_web/docker-compose-prod.yml')
  action :create_if_missing
end

# populate app.env file
app['environment'].each do |test|
  Chef::Log.info("********** The app's environment key is '#{test[0]}' **********")
  Chef::Log.info("********** The app's environment value is '#{test[1]}' **********")
  ruby_block "insert_line" do
    block do
      file = Chef::Util::FileEdit.new("/srv/monkey_web/app.env")
      file.insert_line_if_no_match("/#{test[0]}/", "#{test[0]}=#{test[1]}")
      file.write_file
    end
  end
end

execute 'up containers' do
    cwd '/srv/monkey_web/'
    command 'docker-compose up -d'
    case node[:platform]
    when 'ubuntu'
      environment 'COMPOSE_API_VERSION' => '1.18'
    end
end

# include_recipe 'docker-compose::recreate'


# app = node['deploy']
