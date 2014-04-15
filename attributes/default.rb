default[:apache][:webmaster] = "serversupport@indatus.com"
default[:apache][:apps_root] = "/var/www/apps"
default[:apache][:web_root] = "public"
default[:apache][:owner] = "www-data"
default[:apache][:group] = "www-data"
default[:apache][:sites] = [{:domain => 'localhost.dev', :aka => [], :app_dir => nil, :web_root => nil, :enable_ssl => false}]

default[:apache][:env_vars] = {} #misc env vars for apache

default[:apache][:timeout] = 300
default[:apache][:keep_alive] = 'On'
default[:apache][:max_keep_alive_requests] = 100
default[:apache][:keep_alive_timeout] = 5

default[:apache][:mpm] = 'prefork' #prefork, worker or event
default[:apache][:prefork][:start_servers] = 5
default[:apache][:prefork][:min_spare_servers] = 5
default[:apache][:prefork][:max_spare_servers] = 10
default[:apache][:prefork][:max_clients] = 150
default[:apache][:prefork][:max_requests_per_child] = 0

default[:apache][:worker][:start_servers] = 2
default[:apache][:worker][:min_spare_threads] = 25
default[:apache][:worker][:max_spare_threads] = 75
default[:apache][:worker][:thread_limit] = 64
default[:apache][:worker][:threads_per_child] = 25
default[:apache][:worker][:max_clients] = 150
default[:apache][:worker][:max_requests_per_child] = 0

default[:apache][:event][:start_servers] = 2
default[:apache][:event][:min_spare_threads] = 25
default[:apache][:event][:max_spare_threads] = 75
default[:apache][:event][:thread_limit] = 64
default[:apache][:event][:threads_per_child] = 25
default[:apache][:event][:max_clients] = 150
default[:apache][:event][:max_requests_per_child] = 0
