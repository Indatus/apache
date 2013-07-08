#install apache
%w(vim curl apache2 apache2.2-common apache2-mpm-prefork apache2-utils libexpat1 ssl-cert git-core git-svn).each do |pkg|
  package pkg do
    action :install
  end
end

#make an apache service for restarting etc
service "apache2" do
  supports :restart => true, :start => true, :stop => true, :reload => true
  action :nothing
end 


#enable apache modules
%w(ssl rewrite).each do |mod|
  execute "enable_apache_module" do
   	command "cd /etc/apache2/mods-available && a2enmod #{mod}"
  	action :run
  	notifies :restart, "service[apache2]"
  	not_if do
    	File.exists?("/etc/apache2/mods-enabled/#{mod}.load")
  	end
  end
end

#configure the apache envvars
template "/etc/apache2/envvars" do
  mode 0644
  source "envvars.erb"
end

#create the apache lock dir, and change premissions, 
#but not if it doesn't exist already
directory "/var/lock/apache2" do
  owner node[:apache][:owner]
  group node[:apache][:group]
  recursive true
  mode 0755
  not_if do 
    !File.exists?("/var/lock/apache2")
  end
end


#create the web apps root dir
directory node[:apache][:apps_root] do
	owner node[:apache][:owner]
	group node[:apache][:group]
	recursive true
	mode 0755
	not_if do 
		File.exists?(node[:apache][:apps_root])
	end
end


#disable and remove the default vhost
execute "disable_default_vhost" do
  command "cd /etc/apache2/sites-available && a2dissite default && rm default"
  action :run
  notifies :reload, "service[apache2]"
  not_if do
    !File.exists?("/etc/apache2/sites-available/default")
  end
end


#create the dirs for all our hosted sites
node[:apache][:sites].each do |site|
  
  dir_name = site[:domain].downcase.gsub(/[^\w\.\_]/,'-').gsub(".", "_")
  site_dir = File.join(node[:apache][:apps_root], dir_name)
  
  #create the directory for the site
  directory site_dir do
  	owner node[:apache][:owner]
  	group node[:apache][:group]
  	recursive true
  	mode 0755
  	not_if do 
  		File.exists?(site_dir)
  	end
  end #end directory
  
  #create nested site directories
  [File.join(site_dir, 'public')].each do |dir|
    directory dir do 
      owner node[:apache][:owner]
    	group node[:apache][:group]
    	recursive true
    	mode 0755
    	not_if do 
    		File.exists?(dir)
    	end
    end #end directory
  end #end each
  
  
  #create a vhost config file for each site
  vhost_path = "/etc/apache2/sites-available/#{dir_name}.conf"
  template vhost_path do
    mode 0644
    source "vhost.conf.erb"
    variables site.merge(:dir_name => dir_name)
  end
  
  #create SSL dirs if necessary
  if site[:enable_ssl] == true
    directory "/etc/ssl/#{dir_name}" do 
      owner node[:apache][:owner]
      group node[:apache][:group]
    	recursive true
    	mode 0644
    	not_if do 
    		File.exists?("/etc/ssl/#{dir_name}")
    	end
    end #end directory
    
    #move over the ssl certs if they are present
    cookbook_file "/etc/ssl/#{dir_name}/#{site[:domain]}.crt" do
      owner node[:apache][:owner]
      group node[:apache][:group]
      mode 0644
      action :create_if_missing
      backup 1
    end
    
    cookbook_file "/etc/ssl/#{dir_name}/#{site[:domain]}.key" do
      owner node[:apache][:owner]
      group node[:apache][:group]
      mode 0644
      action :create_if_missing
      backup 1
    end
    
  end #end if
  
  #enable the vhost
  execute "enable_vhost" do
   	command "cd /etc/apache2/sites-available && a2ensite #{dir_name}.conf"
  	action :run
  	notifies :reload, "service[apache2]"
  	not_if do
    	File.exists?(vhost_path.gsub("sites-available", "sites-enabled"))
  	end
  end
  
end #end sites.each



#set server time to UTC
link "/etc/localtime" do
  to "/usr/share/zoneinfo/UTC"
end