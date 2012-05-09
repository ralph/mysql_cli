require 'db_importer/version'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/logger.rb'
require 'cocaine'
require 'yaml'

class DbImporter
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

  def read_credentials_from_config(config_file, env = 'development')
    db_credentials = YAML.load_file(config_file)[env]
    db_credentials.symbolize_keys!
    db_credentials[:host] ||= '127.0.0.1'
    db_credentials[:username] ||= 'root'

    self.credentials = db_credentials
  end

  def sql(file_or_string, ignore_errors = false)
    params = '-h :host -u :username'
    params = "-p:password #{params}" if credentials[:password].present?
    if File.extname(file_or_string) == '.sql'
      params = "#{params} #{credentials[:database]} < :file_path"
      param_values = credentials.merge(file_path: file_or_string.path)
    elsif File.extname(file_or_string) == '.gz'
      params = "< :file_path | mysql #{params} #{credentials[:database]}"
      param_values = credentials.merge(file_path: file_or_string.path)
      param_values.merge!(expected_outcodes: [0, 1]) if ignore_errors
      cl = Cocaine::CommandLine.new('gunzip', params, param_values)
    else
      params = "-e :sql #{params}"
      use_db_sql = "USE #{credentials[:database]}; #{file_or_string}"
      param_values = credentials.merge(sql: use_db_sql)
    end
    param_values.merge!(expected_outcodes: [0, 1]) if ignore_errors
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
