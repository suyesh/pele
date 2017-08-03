module Pele
  module Utils
    def self.get_os_path
      if OS.windows?
        '%USERPROFILE%.awscredentials'
      elsif OS.mac? || OS.linux?
        '~/.aws/credentials'
      else
        puts ''
        say("Looks like we could not identify your OS.\n\nPlease setup your ENV values as follows:\n\nAWS_ACCESS_KEY_ID=[YOUR ACCES KEY ID]\nAWS_SECRET_ACCESS_KEY=[YOUR SECRET KEY ID]", :red)
        abort
      end
    end

    def self.check_existing_file(os, prompt)
      if File.exist? File.expand_path os
        overwrite = prompt.select("This is going to overwrite your existing #{'~/.aws/credentials'.colorize(:green)}. ok?", %w[OK EXIT])
        abort unless overwrite == 'OK'
      end
    end

    def self.post_identification
      puts "\e[H\e[2J"
      say('Your OS identified: ', :yellow)
      puts ''
      puts OS.report
      puts ''
      say('Provide your aws credentials below', :yellow)
      puts ''
    end

    def self.create_key_pair(os, key_pair_name)
      current_dirname = File.basename(Dir.getwd)
      ec2 = Aws::EC2::Client.new
      Dir.chdir File.dirname(os)
      ec2.create_key_pair(key_name: key_pair_name)
      Dir.chdir current_dirname
      create_file "#{File.dirname(os)}key" do
        key_pair_name.to_s
      end
      say('Key-pair successfully generated', :green)
    end
  end
end
