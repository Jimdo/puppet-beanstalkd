# This manifest is the entry point for `rake vagrant:provision`.
# Use it to set up integration tests for this Puppet module.

# Test the module
class { 'beanstalkd':
  start_service => true
}
