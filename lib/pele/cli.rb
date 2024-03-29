require 'fileutils'
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
      aws_access_key_id = prompt.ask('AWS Access Key ID: '.colorize(:blue), required: true).delete(' ')
      aws_secret_access_key = prompt.ask('AWS Secret Access Key: '.colorize(:blue), required: true).delete(' ')
      aws_region = prompt.select('Choose a AWS region: '.colorize(:blue), Pele::Regions::ALL).delete(' ')
      if aws_access_key_id.empty? || aws_secret_access_key.empty? || aws_region.empty?
        say('You need to provide all three credentials. Please try again', :red)
        abort
      end
      create_file os do
        "[default]\naws_access_key_id = #{aws_access_key_id}\naws_secret_access_key = #{aws_secret_access_key}\nregion = #{aws_region}"
      end
      puts ''
      say('Now lets generate AWS key-pair. This is needed to access EC2 Instances', :green)
      puts ''
      key_pair_name = prompt.ask("Name your key-pair. For example: #{'mykeypair'.colorize(:yellow)} :").delete(' ')
      begin
        ec2 = Aws::EC2::Client.new
        key_pair = ec2.create_key_pair(key_name: "#{key_pair_name}-pele")
        create_file (OS.mac? || OS.linux? ? "~/.ssh/#{key_pair.key_name}.pem" : "%HOMEPATH%\\.ssh\\#{key_pair.key_name}.pem") do
          key_pair.key_material
        end
        say('Key-pair successfully generated', :green)
      rescue => e
        say('Something went wrong while trying to create key-pair. Please try again', :cyan)
        puts ''
        puts "Error: #{e}".colorize(:red)
      end
    end
  end
end
