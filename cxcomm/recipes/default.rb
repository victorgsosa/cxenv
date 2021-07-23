#
# Cookbook:: cxcomm
# Recipe:: default
#
# Copyright:: 2020, The Authors, All Rights Reserved.

cxcomm_user 'cxcomm' do
	node['cxcomm']['user'].each do |key, value|
    	# Skip nils, use false if you want to disable something.
    	send(key, value) unless value.nil?
  	end	
end
cxcomm_install 'cxcomm' do
	node['cxcomm']['install'].each do |key, value|
    	# Skip nils, use false if you want to disable something.
    	send(key, value) unless value.nil?
  	end	
end



