module Ngcpconfig
  class Main
    def self.getconfig
      # config file
      $suite_root = File.expand_path "#{File.dirname(__FILE__)}"
      $config = YAML::load(File.read($suite_root+"/../../env.yml"))

      # need to be configured in env.yml
      $admin_host = $config['admin_host']
      if $admin_host.nil?
	$stderr.puts "Error: admin_host variable not defined in env.yml"
	exit 1
      end

      $csc_host = $config['csc_host']
      if $csc_host.nil?
	$stderr.puts "Error: csc_host variable not defined in env.yml"
	exit 1
      end

      # default settings if unset
      $domain = $config['domain']
      $domain = "example.org" if $domain.nil?

      $user = $config['user']
      $user = "sipwise" if $user.nil?

      $mode = $config['mode']
      $mode = "local" if $mode.nil?

      $remote_instance = $config['remote_instance']
      $remote_instance = "http://127.0.0.1:4444/wd/hub" if $remote_instance.nil?

      $phone_cc = $config['phone_cc']
      $phone_cc = "43" if $phone_cc.nil?

      $phone_ac = $config['phone_ac']
      $phone_ac = "99" if $phone_ac.nil?

      $phone_sn = $config['phone_sn']
      $phone_sn = "1001" if $phone_sn.nil?
    end
  end
end
