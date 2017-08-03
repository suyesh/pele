module Pele
  class Cli < Thor
    include Thor::Actions

    desc 'pele init', 'Initializes the AWS credentials on your Machine'
    def init
      os = if OS.windows?
             '%HOMEPATH%\.aws\credentials'
           elsif OS.mac? || OS.linux?
             '~/.aws/credentials'
           end
      if os.nil?
        puts ''
        say("Looks like we could not identify your OS.\n\nPlease setup your ENV values as follows:\n\nAWS_ACCESS_KEY_ID=[YOUR ACCES KEY ID]\nAWS_SECRET_ACCESS_KEY=[YOUR SECRET KEY ID]", :red)
        abort
      end
      prompt = TTY::Prompt.new active_color: :green
      if File.exist? File.expand_path os
        overwrite = prompt.select("This is going to overwrite your existing #{'~/.aws/credentials'.colorize(:green)}. ok?", %w[OK EXIT])
        abort unless overwrite == 'OK'
      end
      puts "\e[H\e[2J"
      say('Your OS identified: ', :yellow)
      puts ''
      puts OS.report
      puts ''
      say('Provide your aws credentials below', :yellow)
      puts ''
      aws_access_key_id = prompt.ask('AWS Access Key ID: '.colorize(:blue), required: true)
      aws_secret_access_key = prompt.ask('AWS Secret Access Key: '.colorize(:blue), required: true)
      aws_region = prompt.select('Choose a AWS region: '.colorize(:blue), Pele::Regions::ALL)
      if aws_access_key_id.empty? || aws_secret_access_key.empty? || aws_region.empty?
        say('You need to provide all three credentials. Please try again', :red)
        abort
      end
      create_file os do
        "[default]\naws_access_key_id = #{aws_access_key_id}\naws_secret_access_key = #{aws_secret_access_key}\nregion = #{aws_region}"
      end
      puts ''
      say('Now lets generate AWS key-pair. This is needed to access EC2 Instances', :green)
      if File.exist? File.expand_path "#{os}key"
        puts ''
        overwrite = prompt.select('Looks like you already have a key generated. Would you like to generate new one?', %w[Yes No])
        abort if overwrite == 'Yes'
      end
      puts ''
      key_pair_name = prompt.ask('Name your key-pair. For example: mykeypair.colorize(:green)')
      begin
        current_dirname = File.basename(Dir.getwd)
        ec2 = Aws::EC2::Client.new
        ec2.create_key_pair(key_name: key_pair_name)
        File.open("~/.ssh/#{key_pair_name}.pem", 'w') do |file|
          file.write key_pair_name
        end
        require 'fileutils'
        FileUtils.chmod(0600, "~/.ssh/#{key_pair_name}.pem")

        say('Key-pair successfully generated', :green)
      rescue => e
        say('Something went wrong while trying to create key-pair. Please try again', :red)
        puts ''
        puts "Error: #{e}"
      end
    end
  end
end
