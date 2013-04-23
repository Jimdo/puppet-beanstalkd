require 'spec_helper'

describe 'beanstalkd' do
  let (:facts) { {:operatingsystem => "debian"} }

  it { should contain_package('beanstalkd').with_ensure('installed') }

  context 'with listen_addr => 1.2.3.4' do
    let (:params) { {:listen_addr => '1.2.3.4'} }

    it do
      should contain_file('beanstalkd_config') \
        .with_content(/^BEANSTALKD_LISTEN_ADDR\=1\.2\.3\.4$/)
    end
  end

  context 'with listen_port => 12345' do
    let (:params) { {:listen_port => '12345'} }

    it do
      should contain_file('beanstalkd_config') \
        .with_content(/^BEANSTALKD_LISTEN_PORT\=12345$/)
    end
  end

  context 'with binlog_dir => "/test/folder/binlog"' do
    let (:params) { {:binlog_dir => '/test/folder/binlog'} }

    it do
      should contain_file('beanstalkd_config') \
        .with_content(/^BEANSTALKD_BINLOG_DIR\=\/test\/folder\/binlog$/)

      should contain_file('beanstalkd_binlog_dir')
    end
  end

  context 'with binlog_max_size => 98765"' do
    let (:params) { {:binlog_max_size => 98765} }

    it do
      should contain_file('beanstalkd_config') \
        .with_content(/^BEANSTALKD_BINLOG_MAX_SIZE\=98765$/)
    end
  end

  context 'with fsync_max => 10' do
    let (:params) { {:fsync_max => 10} }

    it do
      should contain_file('beanstalkd_config') \
        .with_content(/^BEANSTALKD_FSYNC_MAX\=10$/)
    end
  end

  context 'with job_max_size => 87654' do
    let (:params) { {:job_max_size => 87654} }

    it do
      should contain_file('beanstalkd_config') \
        .with_content(/^BEANSTALKD_JOB_MAX_SIZE\=87654$/)
    end
  end
end
