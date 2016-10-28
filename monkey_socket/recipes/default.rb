
# clone repository
app = search("aws_opsworks_app", "shortname:monkey_socket").first
application_git '/srv/monkey_socket' do
  repository 'git@github.com:Criptext/Monkey-Socket.git'
  deploy_key app['app_source']['ssh_key']
end

# make sure file app.env exists
file '/srv/monkey_socket/app.env' do
  action :create_if_missing
end

# create docker-compose file if it doesn't exist
# necessary 'if' because at compile time docker-compose file doesn't exist
if File.exist?('/srv/monkey_socket/docker-compose-prod.yml')
  file '/srv/monkey_socket/docker-compose.yml' do
    content IO.read('/srv/monkey_socket/docker-compose-prod.yml')
    action :create_if_missing
  end
end

# populate app.env file
app['environment'].each do |test|
  ruby_block "insert_line" do
    block do
      file = Chef::Util::FileEdit.new("/srv/monkey_socket/app.env")
      file.insert_line_if_no_match("/#{test[0]}/", "#{test[0]}=#{test[1]}")
      file.write_file
    end
  end
end

include_recipe 'monkey_socket::recreate'
