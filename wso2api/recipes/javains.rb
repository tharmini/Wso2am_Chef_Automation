#
# Cookbook:: wso2api
# Recipe:: javains
#
# Copyright:: 2018, The Authors, All Rights Reserved.

#
file_cache_path = node['wso2am']['java_file_cache_path']
extract_cache_path = node['wso2am']['java_extracted_path']
java_home = node['wso2am']['java_home']
java_home_path = "#{java_home}/bin"
package 'tar'


#adding java to extracted path
bash "adding java to #{extract_cache_path}" do
  cwd ::File.dirname(file_cache_path)
  code <<-EOH
	tar -xvzf "#{file_cache_path}" -C "#{extract_cache_path}"
  EOH
  not_if {::File.exists?(java_home)}
end

#setting java home
ENV['JAVA_HOME'] = java_home
bash 'env_test' do
  code <<-EOH
  echo $JAVA_HOME
  EOH
end

#change the mode
directory '/etc/profile.d' do
  mode '0755'
end

#export java home
file '/etc/profile.d/jdk.sh' do
  content "export JAVA_HOME=#{java_home}"
  content "export PATH=#{java_home_path}"
  mode '0755'
  only_if {node['wso2am']['set_etc_environment'] == true}
end



#ruby_block 'set-env-java-home' do
# block do
# ENV['JAVA_HOME'] = java_home
#  end
#  not_if { ENV['JAVA_HOME'] == java_home }
#end
#


#setting envirnmental variables

ruby_block 'set JAVA_HOME in /etc/environment' do
  block do
    file = Chef::Util::FileEdit.new('/etc/environment')
    file.insert_line_if_no_match(/^JAVA_HOME=/, "JAVA_HOME=#{java_home}")
    file.search_file_replace_line(/^JAVA_HOME=/, "JAVA_HOME=#{java_home}")
    file.write_file
  end
  only_if { node['wso2am']['set_etc_environment'] }
end


