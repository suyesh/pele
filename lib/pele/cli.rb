module Pele
  class Cli < Thor
    include Thor::Actions

    desc 'pele init', 'Initializes the AWS credentials on your Machine'

    def init
      os = Pele::Utils.get_os_path
      prompt = TTY::Prompt.new active_color: :green
      Pele::Utils.check_existing_file(os, prompt)
      Pele::Utils.post_identification
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
      say('Now lets generate AWS key-pair. This is needed to access EC2 Instances', :green)
      puts ''
      if File.exist? File.expand_path "#{os}key"
        overwrite = prompt.select('Looks like you already have a key generated. Would you like to generate new one?', %w[Yes No])
        abort if overwrite == 'Yes'
      end
      puts ''
      key_pair_name = prompt.ask('Name your key-pair. For example: mykeypair.colorize(:green)')
      begin
        Pele::Utils.create_key_pair(os, key_pair_name)
      rescue
        say('Something went wrong while trying to create key-pair. Please try again', :red)
      end
    end
  end
end
