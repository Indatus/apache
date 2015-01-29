case node['platform_family']
 when 'debian'
include_recipe 'apache::debian'
 when 'rhel'
include_recipe 'apache::rhel'
end 
