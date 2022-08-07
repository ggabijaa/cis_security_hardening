# frozen_string_literal: true

require 'spec_helper'

enforce_options = [true, false]

describe 'cis_security_hardening::rules::jffs2' do
  on_supported_os.each do |os, _os_facts|
    enforce_options.each do |enforce|
      context "on #{os} with enforce = #{enforce}" do
        let(:params) do
          {
            'enforce' => enforce,
          }
        end

        it {
          is_expected.to compile
          if enforce
            is_expected.to contain_kmod__install('jffs2')
              .with(
                command: '/bin/true',
              )
          else
            is_expected.not_to contain_kmod__install('jffs2')
          end
        }
      end
    end
  end
end
