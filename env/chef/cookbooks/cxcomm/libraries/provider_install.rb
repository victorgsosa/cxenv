# Chef Resource for installing or removing CX Commerce
module CXCommerceCookbook
  class CXCommerceCookbook::InstallProvider < Chef::Provider::LWRPBase
    include CXCommerceCookbook::Helpers
    include Chef::DSL::IncludeRecipe
    provides :cxcomm_install

    def whyrun_supported?
      true # we only use core Chef resources that also support whyrun
    end

    def action_install
      install_zip_action
    end

    def action_remove
      if new_resource.type == 'tarball'
        remove_tarball_wrapper_action
      elsif new_resource.type == 'package'
        remove_package_wrapper_action
      elsif new_resource.type == 'repository'
        remove_repo_wrapper_action
      else
        raise "#{install_type} is not a valid install type"
      end
    end

    protected


    def install_zip_action
      user = find_cxcomm_resource(Chef.run_context, :cxcomm_user, new_resource)


      java_r = openjdk_pkg_install '11' do
        bin_cmds ["java", "javac"]
        action :nothing
      end
      java_r.run_action(:install)
      new_resource.updated_by_last_action(true) if java_r.updated_by_last_action?



      %w(unzip).each do |p| 
        package_r = package p do
          action :nothing
        end
        package_r.run_action(:install)
        new_resource.updated_by_last_action(true) if package_r.updated_by_last_action?
      end

      unless new_resource.download_url
        raise 'Could not determine download url on this platform'
      end



      ark_r = ark 'hybris' do
        url   new_resource.download_url
        owner user.user
        group user.group
        version new_resource.version
        #has_binaries ['bin/elasticsearch', 'bin/elasticsearch-plugin']
        checksum new_resource.download_checksum
        path   "#{new_resource.dir}"
        strip_components 0
        not_if do
          target = "#{new_resource.dir}/hybris"

          ::File.directory?(target)
        end
        action :nothing
      end
      ark_r.run_action(:put)
      new_resource.updated_by_last_action(true) if ark_r.updated_by_last_action?


      hybris_dir = "#{new_resource.dir}/hybris"
      installer_dir = "#{hybris_dir}/installer"
      password = new_resource.password ? new_resource.password : "admin"
 
      if new_resource.install_ip
        ip_path = "/tmp/ip"
        ip_remote_r = remote_file 'ip' do
          path ip_path
          source new_resource.ip_download_url
          checksum new_resource.ip_download_checksum
          not_if { ::File.exists?(ip_path) }
          owner user.user
          group user.group 
          action :nothing
        end


        ip_remote_r.run_action(:create)
        new_resource.updated_by_last_action(true) if ip_remote_r.updated_by_last_action?
        if ip_remote_r.updated_by_last_action?
          ip_unzip_r = execute 'extract_ip' do
            command "unzip -o #{ip_path} -d #{hybris_dir}"
            user user.user
            group user.group
            action :nothing
          end
          ip_unzip_r.run_action(:run)
          new_resource.updated_by_last_action(true) if ip_unzip_r.updated_by_last_action?
        end
      end

      hybris_env = {'JAVA_HOME' => '/usr/lib/jvm/java-11-openjdk-amd64/'}

      extensions = determine_extensions(new_resource, node)
      storefront = determine_storefront(new_resource, node)

      if new_resource.install_spartacus

        if node['platform_family'] == 'debian'
          node_version = '12.x'
          node_apt_r =  apt_repository "apt-nodejs-repo" do
            uri "https://deb.nodesource.com/node_#{node_version}"
            key 'https://deb.nodesource.com/gpgkey/nodesource.gpg.key'
            components ['main']
            distribution node['lsb']['codename']
            action :nothing # :create, :delete
          end
          node_apt_r.run_action(:add)
          new_resource.updated_by_last_action(true) if node_apt_r.updated_by_last_action?
          node_src_apt_r =  apt_repository "apt-nodejs-repo" do
            uri "https://deb.nodesource.com/node_#{node_version}"
            key 'https://deb.nodesource.com/gpgkey/nodesource.gpg.key'
            components ['main']
            distribution node['lsb']['codename']
            deb_src true
            action :nothing # :create, :delete
          end
          node_src_apt_r.run_action(:add)
          new_resource.updated_by_last_action(true) if node_src_apt_r.updated_by_last_action?
          apt_r =  apt_repository "apt-yarn-repo" do
            uri "https://dl.yarnpkg.com/debian/"
            key 'https://dl.yarnpkg.com/debian/pubkey.gpg'
            components ['main']
            distribution 'stable'
            action :nothing # :create, :delete
          end
          apt_r.run_action(:add)
          new_resource.updated_by_last_action(true) if apt_r.updated_by_last_action?
        else
          yr_r = yum_repository "yum-yarn-repo" do
            baseurl "https://dl.yarnpkg.com/rpm/yarn.repo"
            action :nothing # :add, remove
          end
          yr_r.run_action(:create)
          new_resource.updated_by_last_action(true) if yr_r.updated_by_last_action?
        end

        %w(nodejs yarn).each do |p| 
          package_r = package p do
            action :nothing
          end
          package_r.run_action(:install)
          new_resource.updated_by_last_action(true) if package_r.updated_by_last_action?
        end

        angular_cli_r = npm_package "@angular/cli" do
          version 'v10-lts'
          action :nothing
        end
        angular_cli_r.run_action(:install)
        new_resource.updated_by_last_action(true) if angular_cli_r.updated_by_last_action?

        build_angular_cli_r = npm_package "@angular-devkit/build-angular" do
          version 'v10-lts'
          options ['--save-dev']
          action :nothing
        end
        build_angular_cli_r.run_action(:install)
        new_resource.updated_by_last_action(true) if build_angular_cli_r.updated_by_last_action?

        spartacus_dir = "#{hybris_dir}/hybris/bin/custom"
        spartacus_dir_r = directory spartacus_dir do
          owner user.user
          group user.group
          mode 0755
          action :nothing
        end
        spartacus_dir_r.run_action(:create)
        new_resource.updated_by_last_action(true) if spartacus_dir_r.updated_by_last_action?

        spartacus_download_url = "#{new_resource.spartacus_download_url}/storefront-#{new_resource.spartacus_version}/spartacussampledataaddon.#{new_resource.version}.zip"
        spartacus_ark_r = ark 'spartacussampledataaddon' do
          url  spartacus_download_url 
          owner user.user
          group user.group
          version new_resource.spartacus_version
          #has_binaries ['bin/elasticsearch', 'bin/elasticsearch-plugin']
          checksum new_resource.spartacus_download_checksum
          path   "#{spartacus_dir}"

          not_if do
            target = "#{spartacus_dir}/spartacussampledataaddon"

            ::File.directory?(target)
          end
          action :nothing
        end
        spartacus_ark_r.run_action(:put)
        new_resource.updated_by_last_action(true) if spartacus_ark_r.updated_by_last_action?
        spartacus_extension = "spartacussampledataaddon"
        extensions.append spartacus_extension
        storefront.each {|s| s[:addons].append spartacus_extension unless s[:addons].include? spartacus_extension}

        spartacus_config_dir_r = directory "#{installer_dir}/customconfig" do 
          owner user.user
          group user.group
          mode 0644
          action :nothing
        end
        spartacus_config_dir_r.run_action(:create)
        new_resource.updated_by_last_action(true) if spartacus_config_dir_r.updated_by_last_action?

        spartacus_config_file_r = remote_file "#{installer_dir}/customconfig/custom.properties" do
          source "file://#{spartacus_dir}/spartacussampledataaddon/resources/installer/customconfig/custom.properties"
          owner user.user
          group user.group
          mode 0644
          action :nothing
        end
        spartacus_config_file_r.run_action(:create)
        new_resource.updated_by_last_action(true) if spartacus_config_file_r.updated_by_last_action?
      end 

      recipe_name = new_resource.recipe
      recipe_dir_r = directory "#{installer_dir}/recipes/#{recipe_name}" do
        owner user.user
        group user.group 
        mode 0755
        action :nothing
      end
      recipe_dir_r.run_action(:create)
      new_resource.updated_by_last_action(true) if recipe_dir_r.updated_by_last_action?

      recipe_r = template "#{installer_dir}/recipes/#{recipe_name}/build.gradle" do
          source "build.gradle.erb"
          mode 0644
          owner user.user
          group user.group
          variables(extensions: extensions, storefront: storefront)
          action :nothing
      end
      recipe_r.run_action(:create)
      new_resource.updated_by_last_action(true) if recipe_r.updated_by_last_action?

      Chef::Log.info(::File.exists?("#{installer_dir}/setup") && !recipe_r.updated_by_last_action?)
      setup_r = execute 'setup' do
        user user.user
        group user.group
        cwd installer_dir
        command "./install.sh -r #{recipe_name} -A initAdminPassword=#{password}"
        environment (hybris_env)
        not_if { ::File.exists?("#{installer_dir}/setup") && !recipe_r.updated_by_last_action? } 
        action :nothing
      end
      setup_r.run_action(:run)
      new_resource.updated_by_last_action(true) if setup_r.updated_by_last_action?

      if setup_r.updated_by_last_action?
        setup_file_r = file "#{installer_dir}/setup"  do
          owner user.user
          group user.group
          mode 0644
          action :nothing
        end
        setup_file_r.run_action(:create)
        new_resource.updated_by_last_action(true) if setup_file_r.updated_by_last_action?
      end

      initialize_r = execute 'initialize' do
        user user.user
        group user.group
        cwd installer_dir
        command "./install.sh -r #{recipe_name} initialize -A initAdminPassword=#{password}"
        environment (hybris_env)
        not_if { ::File.exists?("#{installer_dir}/initialized") && !setup_r.updated_by_last_action? }
        action :nothing
      end
      initialize_r.run_action(:run)
      new_resource.updated_by_last_action(true) if initialize_r.updated_by_last_action?

      if initialize_r.updated_by_last_action?
        initialize_file_r = file "#{installer_dir}/initialized"  do
          owner user.user
          group user.group
          mode 0644
          action :nothing
        end
        initialize_file_r.run_action(:create)
        new_resource.updated_by_last_action(true) if initialize_file_r.updated_by_last_action?
      end
    end

    def remove_tarball_wrapper_action
      # remove the symlink to this version
      link_r = link "#{new_resource.dir}/elasticsearch" do
        only_if do
          link   = "#{new_resource.dir}/elasticsearch"
          target = "#{new_resource.dir}/elasticsearch-#{new_resource.version}"

          ::File.directory?(link) && ::File.symlink?(link) && ::File.readlink(link) == target
        end
        action :nothing
      end
      link_r.run_action(:delete)
      new_resource.updated_by_last_action(true) if link_r.updated_by_last_action?

      # remove the specific version
      d_r = directory "#{new_resource.dir}/elasticsearch-#{new_resource.version}" do
        recursive true
        action :nothing
      end
      d_r.run_action(:delete)
      new_resource.updated_by_last_action(true) if d_r.updated_by_last_action?
    end
  end
end
