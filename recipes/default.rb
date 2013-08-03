#
# Author:: Ingo Renner (<ingo@typo3.org>)
# Cookbook Name:: typo3-solr
# Recipe:: default
#
# Copyright 2013, Ingo Renner
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# install requirements
package "zip"
include_recipe "java"
include_recipe "git"


git "Download EXT:solr source, version #{node['ext-solr']['version']}" do
  repository "git://git.typo3.org/TYPO3v4/Extensions/solr.git"
  revision node['ext-solr']['version']
  destination "/var/www/site-#{node['typo3']['site_name']}/typo3conf/ext/solr"
 end

execute "Install Solr server" do
  user "root"
  command "/var/www/site-#{node['typo3']['site_name']}/typo3conf/ext/solr/resources/shell/install-solr.sh"
  creates "/opt/solr-tomcat/solr/solr.xml"
end

unless File.exists? "/opt/solr-tomcat/solr/typo3cores/conf/version-#{node['ext-solr']['version']}.lock"
  Chef::Log.info "Add language specific schema definitions"

  execute "/opt/solr-tomcat/tomcat/bin/shutdown.sh" do
    user "root"
  end

  execute "rm -R /opt/solr-tomcat/solr/typo3cores" do
    user "root"
  end

  execute "cp -R /var/www/site-#{node['typo3']['site_name']}/typo3conf/ext/solr/resources/solr/typo3cores /opt/solr-tomcat/solr/" do
    user "root"
  end

  # create a lock/identification file 
  file "/opt/solr-tomcat/solr/typo3cores/conf/version-#{node['ext-solr']['version']}.lock" do
    action :touch
  end

  execute "/opt/solr-tomcat/tomcat/bin/startup.sh" do
    user "root"
  end
end

#TODO set up tomcat as a service, make it start on boot

