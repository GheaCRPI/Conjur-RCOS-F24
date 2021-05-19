# frozen_string_literal: true

require 'gli'
require 'net/http'
require 'uri'
require 'open3'

require_relative './conjur-cli/commands'

include GLI::App

program_desc "Command and control application for Conjur"
version File.read(File.expand_path("../VERSION", File.dirname(__FILE__)))
arguments :strict
subcommand_option_handling :normal

# Attempt to connect to the database.
def connect
  require 'sequel'

  def test_select
    fail("DATABASE_URL not set") unless ENV['DATABASE_URL']

    begin
      db = Sequel::Model.db = Sequel.connect(ENV['DATABASE_URL'])
      db['select 1'].first
    rescue
      false
    end
  end

  30.times do
    break if test_select

    $stderr.write('.')
    sleep(1)
  end

  raise "Database is still unavailable. Aborting!" unless test_select

  true
end

desc 'Run the application server'
command :server do |c|
  c.desc 'Account to initialize'
  c.arg_name :name
  c.flag [ :a, :account ]

  c.desc "Provide account password via STDIN"
  c.arg_name "password-from-stdin"
  c.switch("password-from-stdin", :negatable => false)

  c.desc 'Policy file to load into the server'
  c.arg_name :path
  c.flag [ :f, :file ]

  c.desc 'Server listen port'
  c.arg_name :port
  c.default_value(ENV['PORT'] || '80')
  c.flag [ :p, :port ]

  c.desc 'Server bind address'
  c.default_value(ENV['BIND_ADDRESS'] || '0.0.0.0')
  c.arg_name :ip
  c.flag [ :b, :'bind-address' ]

  c.action do |global_options,options,args|
    # This call will block the process until the Conjur server process is
    # stopped (e.g. with ctrl+c)
    Commands::Server.new.call(
      account: options[:account],
      password_from_stdin: options["password-from-stdin"],
      file_name: options[:file],
      bind_address: options[:'bind-address'],
      port: options[:port]
    )
  end
end

desc "Manage the policy"
command :policy do |cgrp|
  cgrp.desc "Load MAML policy from file(s)"
  cgrp.arg(:account)
  cgrp.arg(:filename, :multiple)
  cgrp.command :load do |c|
    c.action do |global_options,options,args|
      account, *file_names = args
      
      Commands::Policy::Load.new.call(
        account: account,
        file_names: file_names
      )
    end
  end

  cgrp.desc "Watch a file and reload the policy if it's modified"
  cgrp.long_desc(<<~DESC)
    To trigger a reload of the policy, replace the contents of the watched file
    with the path to the policy. Of course, the path must be visible to the
    container which is running "conjurctl watch". This can be a separate
    container from the application server. Both the application server and the
    policy watcher should share the same backing database.

    Example:

    $ conjurctl watch /run/conjur/policy/load)"
  DESC

  cgrp.arg(:account)
  cgrp.arg(:filename)
  cgrp.command :watch do |c|
    c.action do |global_options,options,args|
      account, file_name = args

      Commands::Policy::Watch.new.call(
        account: account,
        file_name: file_name
      )
    end
  end
end

desc "Manage the data encryption key"
command :"data-key" do |cgrp|
  cgrp.desc "Generate a data encryption key"
  cgrp.long_desc(<<-DESC)
Use this command to generate a new Base64-encoded 256 bit data encrytion key.
Once generated, this key should be placed into the environment of the Conjur
server. It will be used to encrypt all sensitive data which is stored in the
database, including the token-signing private key.


Example:


$ export CONJUR_DATA_KEY="$(conjurctl data-key generate)"
  DESC
  cgrp.command :generate do |c|
    c.action do |global_options,options,args|
      exec("rake data-key:generate")
    end
  end
end

desc "Manage accounts"
command :account do |cgrp|
  cgrp.desc "Create an organization account"
  cgrp.long_desc(<<-DESC)
Use this command to generate and store a new account, along with its 2048-bit 
RSA private key, used to sign auth tokens. The CONJUR_DATA_KEY must be
available in the environment when this command is called, since it's used to
encrypt the token-signing key in the database.

The optional 'password-from-stdin' flag signifies that the password should be 
read from STDIN. If the flag is not provided, the "admin" user API key will be
outputted to STDOUT.

The 'name' flag or command argument must be present. It will specify the name of
the account that will be created.

Example:

$ conjurctl account create [--password-from-stdin] --name myorg
  DESC
  cgrp.arg(:name, :optional)
  cgrp.command :create do |c|
    c.desc("Provide account password via STDIN")
    c.arg_name("password-from-stdin")
    c.switch("password-from-stdin", :negatable => false)

    c.desc("Account name")
    c.arg_name(:name)
    c.flag(:name)

    c.action do |global_options,options,args|
      account = options[:name] || args.first
      raise "No account name was provided" unless account

      connect

      if options["password-from-stdin"]
        # Rake is interpreting raw commas in the password as
        # delimiting addtional arguments to rake itself. 
        # Reference: https://github.com/ruby/rake/blob/a842fb2c30cc3ca80803fba903006b1324a62e9a/lib/rake/application.rb#L163
        password = stdin_input.gsub(',', '\,')
        exec("rake 'account:create_with_password[#{account},#{password}]'")
      else
        exec("rake 'account:create[#{account}]'")
      end
    end
  end

  cgrp.desc "Delete an organization account"
  cgrp.arg(:account)
  cgrp.command :delete do |c|
    c.action do |global_options,options,args|
      account = args.first
      connect

      exec("rake 'account:delete[#{account}]'")
    end
  end
end

desc "Manage the database"
command :db do |cgrp|
  cgrp.desc "Create and/or upgrade the database schema"
  cgrp.command :migrate do |c|
    c.action do |global_options,options,args|
      connect

      exec("rake db:migrate")
    end
  end
end

desc "Manage roles"
command :role do |cgrp|
  cgrp.desc "Retrieve a role's API key"
  cgrp.arg(:role_id, :multiple)
  cgrp.command :"retrieve-key" do |c|
    c.action do |global_options,options,args|
      connect

      fail 'key retrieval failed' unless args.map { |id|
        stdout, stderr, = Open3.capture3("rake 'role:retrieve-key[#{id}]'")

        if stderr.empty?
          # Only print last line of stdout to omit server config logging
          puts(stdout.split("\n").last)
          true
        else
          $stderr.puts(stderr)
          false
        end
      }.all?
    end
  end
end

desc "Wait for the Conjur server to be ready"
command :wait do |c|
  c.desc 'Port'
  c.arg_name :port
  c.default_value(ENV['PORT'] || '80')
  c.flag [ :p, :port ], :must_match => /\d+/

  c.desc 'Number of retries'
  c.arg_name :retries
  c.default_value(90)
  c.flag [ :r, :retries ], :must_match => /\d+/

  c.action do |global_options,options,args|
    puts "Waiting for Conjur to be ready..."

    retries = options[:retries].to_i
    port = options[:port]

    conjur_ready = lambda do
      uri = URI.parse("http://localhost:#{port}")
      begin
        response = Net::HTTP.get_response(uri)
        response.code.to_i < 300
      rescue
        false
      end
    end

    retries.times do
      break if conjur_ready.call

      STDOUT.print(".")
      sleep 1
    end

    if conjur_ready.call
      puts " Conjur is ready!"
    else
      exit_now! " Conjur is not ready after #{retries} seconds" 
    end
  end
end

desc 'Export the Conjur data for migration to Conjur Enteprise Edition'
command :export do |c|
  c.desc 'Output directory'
  c.arg_name :out_dir
  c.default_value(Dir.pwd)
  c.flag [:o, :out_dir]

  c.desc 'Label to use for archive filename'
  c.arg_name :label
  c.default_value(Time.now.strftime('%Y-%m-%dT%H-%M-%SZ'))
  c.flag [:l, :label]

  c.action do |global_options,options,args|
    connect
    exec(%(rake export["#{options[:out_dir]}","#{options[:label]}"]))
  end
end

exit run(ARGV)
