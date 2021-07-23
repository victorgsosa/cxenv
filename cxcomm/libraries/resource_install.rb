# Chef Resource for installing or removing CX Commerce
module CXCommerceCookbook
  class CXCommerceCookbook::InstallResource < Chef::Resource::LWRPBase
    resource_name :cxcomm_install
    provides :cxcomm_install

    actions(:install, :remove)
    default_action :install

    # this is what helps the various resources find each other
    attribute(:instance_name, kind_of: String)

    # if this version parameter is not set by the caller, we look at
    # `attributes/default.rb` for a default value to use, or we raise
    attribute(:version, kind_of: String, default: '2005')

    # these use `attributes/default.rb` for default values per platform and install type
    attribute(:download_url, kind_of: String, default: '')
    attribute(:download_checksum, kind_of: String) # sha256

    # where to install?
    attribute(:dir, kind_of: String, default: '/usr/share/cxcomm')

    attribute(:password, kind_of: String, default: nil)
    attribute(:recipe, kind_of: String, default: "chef")
    attribute(:extensions, kind_of: Array, default: [])
    attribute(:storefront, kind_of: Hash, default: {})

    attribute(:install_spartacus, kind_of: [TrueClass, FalseClass], default: false)

    attribute(:spartacus_version, kind_of: String, default: "2.0.0")
    attribute(:spartacus_download_url, kind_of: String, default: "https://github.com/SAP/spartacus/releases/download/")
    attribute(:spartacus_download_checksum, kind_of: String, default: "1b4c3a526e03a606828f900a15050b53f3691c435289b39754aeabc97c939102") # sha256

    attribute(:install_ip, kind_of: [TrueClass, FalseClass], default: false)
    # these use `attributes/default.rb` for default values per platform and install type
    attribute(:ip_download_url, kind_of: String, default: '')
    attribute(:ip_download_checksum, kind_of: String) # sha256

    attribute(:ip_addons, kind_of: Array, default: [])
  end
end
