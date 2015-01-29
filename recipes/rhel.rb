#install apache
%w(httpd httpd-tools mod_ssl openssl openssl-devel openssl-static).each do |pkg|
  package pkg do
    action :install
  end
end

#make an apache service for restarting etc
service "httpd" do
  supports :restart => true, :start => true, :stop => true, :reload => true
  action :nothing
end 

#creat the apache lock dir, and change premissions,
##but not if it doesn't exist already
directory "/etc/httpd/vhosts" do
  owner "root"
  group "root"
  recursive true
  mode 0755
  action :create
  not_if { File.exist?("/etc/httpd/vhosts") } 
end

#configure the apache config
template "/etc/httpd/conf/httpd.conf" do
  mode 0644
  source "httpd.conf.erb"
  notifies :restart, "service[httpd]"
end

#create the web apps root dir
directory node['apache']['apps_root'] do
	owner node['apache']['owner']
	group node['apache']['group']
	recursive true
	mode 0755
	not_if do 
		File.exists?(node['apache']['apps_root'])
	end
end


#disable and remove the default vhost
execute "clean /etc/httpd/conf.d" do
  command "cd /etc/httpd/conf.d/ && rm -f welcome.conf && rm -f README"
  action :run
  notifies :reload, "service[httpd]"
  not_if do
    !File.exists?("/etc/httpd/conf.d/welcome.conf")
  end
end

#create the dirs for all our hosted sites
node['apache']['sites'].each do |site|
  
  domain_string = site[:domain].downcase.gsub("*", "star").gsub(/[^\w\.\_]/,'-')

  unless site[:app_dir].nil?
    dir_name = site[:app_dir]
  else 
    dir_name = domain_string
  end
  site_dir = File.join(node['apache']['apps_root'], dir_name)
  
  #create the directory for the site
  directory site_dir do
  	owner node['apache']['owner']
  	group node['apache']['group']
  	recursive true
  	mode 0755
  	not_if do 
  		File.exists?(site_dir)
  	end
  end #end directory
 
  unless site['web_root'].nil?
    web_root = File.join(site_dir, site['web_root'])
  else
    web_root = File.join(site_dir, node['apache']['web_root'])
  end

  #create nested site directories
  [web_root].each do |dir|
    directory dir do 
      owner node['apache']['owner']
    	group node['apache']['group']
    	recursive true
    	mode 0755
    	not_if do 
    		File.exists?(dir)
    	end
    end #end directory
  end #end each
  
  
  #create a vhost config file for each site
  vhost_path = "/etc/httpd/vhosts/#{domain_string}.conf"
  template vhost_path do
    mode 0644
    source "vhost.conf.erb"
    variables site.merge(
      :web_root => web_root, 
      :dir_name => dir_name, 
      :domain_string => domain_string)
  end
  
  #create SSL dirs if necessary
  if site[:enable_ssl] == true
    directory "/etc/httpd/ssl/#{domain_string}" do 
      owner "root"
      group "root"
    	recursive true
    	mode 0644
    	not_if do 
    		File.exists?("/etc/httpd/ssl/#{domain_string}")
    	end
    end #end directory
    
    #move over the ssl certs if they are present
    cookbook_file "/etc/httpd/ssl/#{domain_string}/#{site[:domain]}.crt" do
      owner "root"
      group "root"
      mode 0644
      action :create_if_missing
      backup 1
    end
    
    cookbook_file "/etc/httpd/ssl/#{domain_string}/#{site[:domain]}.key" do
      owner "root"
      group "root"
      mode 0644
      action :create_if_missing
      backup 1
    end
    
    service "httpd" do
      action [ :enable, :start ]
      notifies :restart, :immediately
    end
end
end
