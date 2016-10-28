execute 'stop containers' do
    cwd '/srv/monkey_socket/'
    command 'docker-compose stop'
    case node[:platform]
    when 'ubuntu'
      environment 'COMPOSE_API_VERSION' => '1.18'
    end
end
