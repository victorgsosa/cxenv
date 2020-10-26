module CXCommerceCookbook
class CXCommerceCookbook::ServiceResource < Chef::Resource::LWRPBase
  resource_name :cxcomm_service
  provides :cxcomm_service

  actions(
    :configure, :remove, # our custom actions
    :enable, :disable, :start, :stop, :restart, :status # passthrough to service resource
  )
  default_action :configure

  # this is what helps the various resources find each other
  attribute(:instance_name, kind_of: String, default: nil)

  attribute(:service_name, kind_of: String, name_attribute: true)
  attribute(:args, kind_of: String, default: '-d')

  # service actions
  attribute(:service_actions, kind_of: [Symbol, String, Array], default: [:enable, :start].freeze)

  # allow overridable systemd unit
  attribute(:systemd_source, kind_of: String, default: 'systemd_unit.erb')
  attribute(:systemd_cookbook, kind_of: String, default: 'cxcomm')
end

end