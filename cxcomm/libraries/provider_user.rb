module CXCommerceCookbook

	class CXCommerceCookbook::UserProvider < Chef::Provider::LWRPBase
		include Chef::DSL::IncludeRecipe

		provides :cxcomm_user

		def whyrun_supported?
	      true # we only use core Chef resources that also support whyrun
	    end


		def action_create
			group new_resource.group

			user new_resource.user do
				comment 'CX Commerce user'
				gid new_resource.group
				home new_resource.base_dir
				shell '/bin/bash'
				system true
			end

			directory new_resource.base_dir do
				mode '0755'
				owner new_resource.user
				group new_resource.group
				recursive true
			end
		end

	end
end