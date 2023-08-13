# @summary
#    Ensure the operating system generates an audit record when there are successful/unsuccessful attempts to use the 
#    "delete_module" command
#
# Successful/unsuccessful uses of the delete_module command must generate an audit record.
#
# Rationale:
# Without generating audit records that are specific to the security and mission needs of the organization, it would be 
# difficult to establish, correlate, and investigate the events relating to an incident or identify those responsible for one.
#
# Audit records can be generated from various components within the information system (e.g., module or policy filter). The "delete_module" 
# command is used to unload a kernel module.
#
# When a user logs on, the AUID is set to the UID of the account that is being authenticated.
#
# Daemons are not user sessions and have the loginuid set to "-1". The AUID representation is an unsigned 32-bit integer, which 
# equals "4294967295". The audit system interprets "- 1", "4294967295", and "unset" in the same way.
#
# Satisfies: SRG-OS-000062-GPOS-00031, SRG-OS-000037-GPOS-00015, SRG-OS-000042- GPOS-00020, SRG-OS-000062-GPOS-00031, 
# SRG-OS-000392-GPOS-00172, SRG-OS- 000462-GPOS-00206, SRG-OS-000471-GPOS-00215
#
# @param enforce
#    Enforce the rule.
#
# @example
#   class { 'cis_security_hardening::rules::auditd_delete_module':
#     enforce => true,
#   }
#
# @api private
class cis_security_hardening::rules::auditd_delete_module (
  Boolean $enforce = false,
) {
  if $enforce {
    $uid = fact('cis_security_hardening.auditd.uid_min') ? {
      undef => '1000',
      default => fact('cis_security_hardening.auditd.uid_min'),
    }
    if $facts['os']['famlily'].downcase() == 'redhat' and $facts['os']['release']['major'] >= '9' {
      concat::fragment { 'watch delete_module command rule 1':
        order   => '221',
        target  => $cis_security_hardening::rules::auditd_init::rules_file,
        content => "-a always,exit -F arch=b32 -S delete_module -F auid>=${uid} -F auid!=4294967295 -F key=modules",
      }

      if $facts['os']['architecture'] == 'x86_64' or $facts['os']['architecture'] == 'amd64' {
        concat::fragment { 'watch delete_module command rule 2':
          order   => '222',
          target  => $cis_security_hardening::rules::auditd_init::rules_file,
          content => "-a always,exit -F arch=b64 -S delete_module -F auid>=${uid} -F auid!=4294967295 -F key=modules",
        }
      }
    } else {
      concat::fragment { 'watch delete_module command rule 1':
        order   => '221',
        target  => $cis_security_hardening::rules::auditd_init::rules_file,
        content => "-a always,exit -F arch=b32 -S delete_module -F auid>=${uid} -F auid!=4294967295 -k module_chng",
      }

      if $facts['os']['architecture'] == 'x86_64' or $facts['os']['architecture'] == 'amd64' {
        concat::fragment { 'watch delete_module command rule 2':
          order   => '222',
          target  => $cis_security_hardening::rules::auditd_init::rules_file,
          content => "-a always,exit -F arch=b64 -S delete_module -F auid>=${uid} -F auid!=4294967295 -k module_chng",
        }
      }
    }
  }
}
