module Pele
  class Cli < Thor
    include Thor::Actions

    desc 'pele init', 'Initializes the AWS credentials on your Machine'
    def init
      os = OS.windows? || OS.mac? || OS.linux?
      unless os
        puts ''
        say("Looks like we could not identify your OS.\n\nPlease setup your ENV values as follows:\n\nAWS_ACCESS_KEY_ID=[YOUR ACCES KEY ID]\nAWS_SECRET_ACCESS_KEY=[YOUR SECRET KEY ID]", :red)
        abort
      end
      prompt = TTY::Prompt.new active_color: :green
      if File.exist? File.expand_path '~/.aws/credentials'
        overwrite = prompt.select("This is going to overwrite your existing #{'~/.aws/credentials'.colorize(:green)}. ok?", %w[OK EXIT])
        abort unless overwrite == 'OK'
        puts ' '
      end
      puts "\e[H\e[2J"
      say('Your OS identified: ', :yellow)
      puts ''
      puts OS.report
      puts ''
      say('Provide your aws credentials below', :yellow)
      puts ''
      _aws_access_key_id = prompt.ask('AWS Access Key ID: '.colorize(:blue), required: true)
      _aws_secret_access_key = prompt.ask('AWS Secret Access Key: '.colorize(:blue), required: true)
      _aws_region = prompt.select('Choose a AWS region: '.colorize(:blue), Pele::Regions::ALL)
      if _aws_access_key_id.empty? || _aws_secret_access_key.empty? || _aws_region.empty?
        say('You need to provide all three credentials. Please try again', :red)
        abort
      end
      if OS.windows?
        create_file '%USERPROFILE%.awscredentials' do
          "[default]\naws_access_key_id = #{_aws_access_key_id}\naws_secret_access_key = #{_aws_secret_access_key}\naws_region = #{_aws_region}"
        end
      else
        create_file '~/.aws/credentials' do
          "[default]\naws_access_key_id = #{_aws_access_key_id}\naws_secret_access_key = #{_aws_secret_access_key}\naws_region = #{_aws_region}"
        end
      end
    end
  end
end
