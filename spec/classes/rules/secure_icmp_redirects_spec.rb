# frozen_string_literal: true

require 'spec_helper'

enforce_options = [true, false]

describe 'cis_security_hardening::rules::secure_icmp_redirects' do
  on_supported_os.each do |os, os_facts|
    enforce_options.each do |enforce|
      context "on #{os}" do
        let(:facts) { os_facts }
        let(:params) do
          {
            'enforce' => enforce,
          }
        end

        it {
          is_expected.to compile

          if enforce
            is_expected.to contain_sysctl('net.ipv4.conf.all.secure_redirects')
              .with(
                'value' => 0,
              )
            is_expected.to contain_sysctl('net.ipv4.conf.default.secure_redirects')
              .with(
                'value' => 0,
              )
          else
            is_expected.not_to contain_sysctl('net.ipv4.conf.all.secure_redirects')
            is_expected.not_to contain_sysctl('net.ipv4.conf.default.secure_redirects')
          end
        }
      end
    end
  end
end
