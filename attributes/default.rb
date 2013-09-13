default[:apache][:webmaster] = "serversupport@indatus.com"
default[:apache][:apps_root] = "/var/www/apps"
default[:apache][:app_dir] = nil
default[:apache][:web_root] = "public"
default[:apache][:owner] = "www-data"
default[:apache][:group] = "www-data"
default[:apache][:sites] = [{:domain => 'localhost.dev', :aka => [], :enable_ssl => false}]
