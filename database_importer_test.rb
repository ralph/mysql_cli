require 'minitest/autorun'
require './database_importer'

class DatabaseImporterTest < MiniTest::Unit::TestCase
  def setup
    @dbi = DatabaseImporter.new
    @dbi.read_credentials_from_config('database.yml')
  end



  class Credentials < self
    def test_credentials_can_bet_set
      credentials = { host: '127.0.0.1', user: 'root' }
      @dbi.credentials = credentials
      assert_equal credentials, @dbi.credentials
    end

    def test_read_credentials_from_config
      @dbi.read_credentials_from_config('database.yml')
      refute @dbi.credentials.values_at(:host, :username).include?(nil)
    end
  end



  class Sql < self
    def test_sql_string
      expected = "mysql -e 'show databases' -h '127.0.0.1' -u 'root'"
      assert_equal expected, @dbi.sql('show databases')
    end

    def test_sql_file
      expected = "mysql -h '127.0.0.1' -u 'root' application_development < 'dump.sql'"
      assert_equal expected, @dbi.sql(File.new('dump.sql'))
    end

    def test_gzipped_sql_file
      expected = "gunzip < 'dump.sql.gz' | mysql -h '127.0.0.1' -u 'root' application_development"
      assert_equal expected, @dbi.sql(File.new('dump.sql.gz'))
    end
  end


  class DeleteAndRecreateDb < self
    def test_delete_and_recreate_db
      assert_includes @dbi.delete_and_recreate_db, 'drop database'
      assert_includes @dbi.delete_and_recreate_db, 'create database'
    end
  end
end
