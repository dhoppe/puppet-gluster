require 'spec_helper'

describe 'gluster', :type => :class do
  on_supported_os.each do |os, facts|
    context "on #{os} with all defaults" do
      let(:facts) do
        facts
      end
      it { should compile.with_all_deps }

      it 'should include classes' do
        should contain_class('gluster::install')
        should contain_class('gluster::service')
      end
      it 'should create gluster::install' do
        should create_class('gluster::install').with(
          :server         => true,
          :server_package => 'glusterfs-server',
          :client         => true,
          :client_package => 'glusterfs-fuse',
          :version        => 'LATEST',
          :repo           => true,
        )
      end
      it 'should manage the Gluster service' do
        should create_class('gluster::service').with(
          :ensure => true,
        )
      end
    end
    context 'specific version and package names defined' do
      let :params do {
        :server_package => 'custom-gluster-server',
        :client_package => 'custom-gluster-client',
        :version        => '3.1.4',
        :repo           => false,
      }
      end
      it 'should create gluster::install' do
        should create_class('gluster::install').with(
          :server         => true,
          :server_package => 'custom-gluster-server',
          :client         => true,
          :client_package => 'custom-gluster-client',
          :version        => '3.1.4',
          :repo           => false,
        )
      end
      it 'should manage the Gluster service' do
        should create_class('gluster::service').with(
          :ensure => true,
        )
      end
    end

    context 'when volumes defined' do
      let :params do
        { :volumes =>
          {
            'data1' => {
              'replica' => 2,
              'bricks'  => ['srv1.local:/brick1/brick', 'srv2.local:/brick1/brick'],
              'options' => ['server.allow-insecure: on'],
            }
          }
        }
      end
      it 'should create gluster::volume' do
        should contain_gluster__volume('data1').with(
          :name => 'data1',
          :replica => 2,
          :bricks  => ['srv1.local:/brick1/brick', 'srv2.local:/brick1/brick'],
          :options => ['server.allow-insecure: on'],
        )
      end
    end

    context 'when volumes incorrectly defined' do
      let :params do
        { :volumes =>
          {
            'data1' => %w(this is an array)
          }
        }
      end
      it 'should fail' do
        expect {
          should contain_gluster__volume('data1')
        }.to raise_error(Puppet::Error, //)
      end
    end
  end
end
