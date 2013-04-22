# vi: set ft=ruby :

Vagrant::Config.run do |config|
  config.vm.box = 'jimdo-debian-6.0.7'
  config.vm.box_url = 'https://jimdo-vagrant-boxes.s3.amazonaws.com/jimdo-debian-6.0.7.box'
  config.vm.host_name = 'skeleton-debian'

  # FIXME we can bind the root github folder to /etc/puppet/modules/... this way,
  #       but dependencies won't be handled.
  config.vm.share_folder('beanstalk_module', '/etc/puppet/modules/beanstalkd', '.')

  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = 'manifests'
    puppet.manifest_file  = 'init.pp'
    puppet.options = '--verbose --debug'
  end
end
