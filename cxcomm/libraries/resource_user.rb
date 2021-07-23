module CXCommerceCookbook
	class CXCommerceCookbook::UserResource < Chef::Resource::LWRPBase
		resource_name :cxcomm_user
		provides :cxcomm_user

		actions(:create)

		default_action :create

		attribute(:user, kind_of: String, default: 'cxcomm')
		attribute(:group, kind_of: String, default: 'cxcomm')
		attribute(:base_dir, kind_of: String, default: '/usr/share/cxcomm')

	end
end