default['apache']['webmaster'] = "serversupport@indatus.com"
default['apache']['servername'] = node['fqdn']
default['apache']['apps_root'] = "/var/www/apps"
default['apache']['web_root'] = "public"
default['apache']['group'] = "www-data"
default['apache']['owner'] = case node['platform_family']
when  'debian'
  'www-data'
when 'rhel'
  'apache'
end

default['apache']['sites'] = [{:domain => 'localhost.dev', :aka => [], :app_dir => nil, :web_root => nil, :enable_ssl => false}]

default['apache']['env_vars'] = {} #misc env vars for apache

default['apache']['timeout'] = 300
default['apache']['keep_alive'] = 'On'
default['apache']['max_keep_alive_requests'] = 100
default['apache']['keep_alive_timeout'] = 15

default['apache']['mpm'] = 'prefork' #prefork, worker or event
default['apache']['prefork']['start_servers'] = 5
default['apache']['prefork']['min_spare_servers'] = 5
default['apache']['prefork']['max_spare_servers'] = 10
default['apache']['prefork']['max_clients'] = 150
default['apache']['prefork']['max_requests_per_child'] = 100
