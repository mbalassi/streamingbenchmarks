#
# DO NOT EDIT THIS FILE DIRECTLY - UNLESS YOU KNOW WHAT YOU ARE DOING
#

user node[:streamingbenchmarks][:user] do
  action :create
  supports :manage_home => true
  home "/home/#{node[:streamingbenchmarks][:user]}"
  shell "/bin/bash"
  not_if "getent passwd #{node[:streamingbenchmarks]['user']}"
end

group node[:streamingbenchmarks][:group] do
  action :modify
  members ["#{node[:streamingbenchmarks][:user]}"]
  append true
end


private_ip = my_private_ip()
public_ip = my_public_ip()



# Pre-Experiment Code


# Configuration Files

directory "#{node[:streamingbenchmarks][:home]}" do
  owner node[:streamingbenchmarks][:user]
  group node[:streamingbenchmarks][:group]
  mode "755"
  action :create
  recursive true
  not_if { File.directory?("#{node[:streamingbenchmarks][:home]}") }
end

directory "#{node[:streamingbenchmarks][:home]}/Test" do
  owner node[:streamingbenchmarks][:user]
  group node[:streamingbenchmarks][:group]
  mode "755"
  action :create
  not_if { File.directory?("#{node[:streamingbenchmarks][:home]}/Test") }
end


directory "#{node[:streamingbenchmarks][:home]}/Test/data" do
  owner node[:streamingbenchmarks][:user]
  group node[:streamingbenchmarks][:group]
  mode "755"
  action :create
  not_if { File.directory?("#{node[:streamingbenchmarks][:home]}/Test/data") }
end

directory "#{node[:streamingbenchmarks][:home]}/conf" do
  owner node[:streamingbenchmarks][:user]
  group node[:streamingbenchmarks][:group]
  mode "755"
  action :create
  recursive true
  not_if { File.directory?("#{node[:streamingbenchmarks][:home]}/conf") }
end

directory "#{node[:streamingbenchmarks][:home]}/bin" do
  owner node[:streamingbenchmarks][:user]
  group node[:streamingbenchmarks][:group]
  mode "755"
  action :create
  recursive true
  not_if { File.directory?("#{node[:streamingbenchmarks][:home]}/bin") }
end

remote_file "#{node[:streamingbenchmarks][:home]}/Test/data/tweets.txt"  do
  source "http://snurran.sics.se/hops/tweets.txt"
  checksum "4db5026349dd57febf4a68d56b7f1a2769df4eb6bd6b44a8155fe56f551903f7"
  mode 0755
  action :create
end

bench="intel-benchmarks.tgz"

remote_file "/tmp/#{bench}"  do
  source "http://snurran.sics.se/hops/#{bench}"
  mode 0755
  action :create
end


bash "unpack_intel_benchmarks" do
  user node['streamingbenchmarks']['user']
  group node['streamingbenchmarks']['group']
    code <<-EOF
cd /tmp
tar -xzf #{bench} -C #{node[:streamingbenchmarks][:home]}/bin
touch #{node[:streamingbenchmarks][:home]}/.benchmarks_downloaded
EOF
  not_if { ::File.exists?( "#{node[:streamingbenchmarks][:home]}/.benchmarks_downloaded" ) }
end


template "#{node[:streamingbenchmarks][:home]}/conf/benchmark.properties" do
  source "benchmark.properties.erb"
  owner node[:streamingbenchmarks][:user]
  group node[:streamingbenchmarks][:group]
  mode 0755
end

