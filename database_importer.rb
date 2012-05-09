ENV['RAILS_ENV'] ||= 'development'

require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/logger.rb'
require 'cocaine'
require 'yaml'

class DatabaseImporter
  attr_accessor *[
    :credentials,
    :dry_run,
    :import_file,
    :log,
  ]

  def initialize
    self.dry_run = true
    self.log = false
  end

  def read_credentials_from_config(config_file)
    db_credentials = YAML.load_file(config_file)[ENV['RAILS_ENV']]
    db_credentials.symbolize_keys!
    db_credentials[:host] ||= '127.0.0.1'
    db_credentials[:username] ||= 'root'

    self.credentials = db_credentials
  end

  def sql(file_or_string)
    params = '-h :host -u :username'
    params = "-p:password #{params}" if credentials[:password].present?
    if File.extname(file_or_string) == '.sql'
      params = "#{params} #{credentials[:database]} < :file_path"
      param_values = credentials.merge(file_path: file_or_string.path)
    elsif File.extname(file_or_string) == '.gz'
      params = "< :file_path | mysql #{params} #{credentials[:database]}"
      param_values = credentials.merge(file_path: file_or_string.path)
      cl = Cocaine::CommandLine.new('gunzip', params, param_values)
    else
      params = "-e :sql #{params}"
      param_values = credentials.merge(sql: file_or_string)
    end
    cl ||= Cocaine::CommandLine.new('mysql', params, param_values)
    run cl
  end

  def delete_and_recreate_db
    sql_string =<<-EOS
      drop database #{credentials[:database]};
      create database #{credentials[:database]};
    EOS
    sql sql_string
  end

  def run(cl)
    puts cl.command if log
    dry_run? ? cl.command : cl.run
  end

  def dry_run?
    !!dry_run
  end
end
