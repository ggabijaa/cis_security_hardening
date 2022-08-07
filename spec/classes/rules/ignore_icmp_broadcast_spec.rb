# frozen_string_literal: true

require 'spec_helper'

enforce_options = [true, false]

describe 'cis_security_hardening::rules::ignore_icmp_broadcast' do
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
            is_expected.to contain_sysctl('net.ipv4.icmp_echo_ignore_broadcasts')
              .with(
                'value' => 1,
              )
          else
            is_expected.not_to contain_sysctl('net.ipv4.icmp_echo_ignore_broadcasts')
          end
        }
      end
    end
  end
end
