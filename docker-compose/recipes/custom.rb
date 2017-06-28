#
# Cookbook Name:: docker_compose
# Recipe:: installation
#
# Copyright (c) 2016 Sebastian Boschert, All Rights Reserved.

package 'Install Docker' do
  case node[:platform]
  when 'redhat', 'centos', 'amazon'
    package_name 'docker'
  when 'ubuntu', 'debian'
    package_name 'docker.io'
  end
end

service 'Docker' do
  service_name 'docker'
  supports restart: true, reload: true
  action %w(enable start)
end

def get_install_url
  release = node['docker_compose']['release']
  kernel_name = node['kernel']['name']
  machine_hw_name = node['kernel']['machine']
  "https://github.com/docker/compose/releases/download/1.9.0/docker-compose-Linux-x86_64"
end

command_path = "/usr/local/bin/docker-compose"
install_url = get_install_url

package 'curl' do
  action :install
end

directory '/etc/docker-compose' do
  action :create
  owner 'root'
  group 'docker'
  mode '0750'
end

execute 'install docker-compose' do
  action :run
  command "curl -sSL #{install_url} > #{command_path} && chmod +x #{command_path}"
  creates command_path
  user 'root'
  group 'docker'
  umask '0027'
end

include_recipe 'docker-compose::cron'
