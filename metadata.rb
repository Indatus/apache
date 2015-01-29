name             'apache'
maintainer       'Indatus'
maintainer_email 'devops@indatus.com'
description       "Configures apache"
license 	  'Apache v2.0'
version           "1.0"
supports          'ubuntu'
supports 	  'debian'
supports	  'centos'
supports  	  'scientific'
supports   	  'redhat'
supports 	  'fedora'
depends           "build-essential"
depends		  'yum'
provides	  'apache::debian'
provides	  'apache::rhel'
recipe		  'apache::debian', "Installs Apache2 on debian family distributions. Depends on platform_family from ohai"
recipe		  'apache::rhel', "Installs Apache2 on rhel family distributions. Depends on platform_family from ohai"
version		  '2.0.0'
