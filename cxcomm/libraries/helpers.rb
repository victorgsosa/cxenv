module CXCommerceCookbook

	module Helpers
		def find_cxcomm_resource(run_context, resource_type, resource)
	      resource_name = resource.name
	      instance_name = resource.instance_name

	      # if we are truly given a specific name to find
	      name_match = find_exact_resource(run_context, resource_type, resource_name) rescue nil
	      return name_match if name_match

	      # first try by instance name attribute
	      name_instance = find_instance_name_resource(run_context, resource_type, instance_name) rescue nil
	      return name_instance if name_instance

	      # otherwise try the defaults
	      name_default = find_exact_resource(run_context, resource_type, 'default') rescue nil
	      name_cxcomm = find_exact_resource(run_context, resource_type, 'cxcomm') rescue nil

	      # if we found exactly one default name that matched
	      return name_default if name_default && !name_cxcomm
	      return name_cxcomm if name_cxcomm && !name_default

	      raise "Could not find exactly one #{resource_type} resource, and no specific resource or instance name was given"
   		end
	    # find exactly the resource name and type, but raise if there's multiple matches
	    # see https://github.com/chef/chef/blob/master/lib/chef/resource_collection/resource_set.rb#L80
	    def find_exact_resource(run_context, resource_type, resource_name)
	      rc = run_context.resource_collection
	      result = rc.find(resource_type => resource_name)

	      if result && result.is_a?(Array)
	        str = ''
	        str << "more than one #{resource_type} was found, "
	        str << 'you must specify a precise resource name'
	        raise str
	      end

	      result
	    end

	    def find_instance_name_resource(run_context, resource_type, instance_name)
	      results = []
	      rc = run_context.resource_collection

	      rc.each do |r|
	        next unless r.resource_name == resource_type && r.instance_name == instance_name
	        results << r
	      end

	      if !results.empty? && results.length > 1
	        str = ''
	        str << "more than one #{resource_type} was found, "
	        str << 'you must specify a precise instance name'
	        raise str
	      elsif !results.empty?
	        return results.first
	      end

	      nil # falsey
	    end

	    def determine_extensions(new_resource, node)
	    	unless new_resource.extensions.empty?
	    		return new_resource.extensions
	    	end
	    	return node['cxcomm']['extensions'].dup
	    end

	    def determine_storefront(new_resource, node)
	    	unless new_resource.storefront.empty?
	    		return new_resource.storefront
	    	end
	    	return node['cxcomm']['storefront'].dup
	    end
	end
end