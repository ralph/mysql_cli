require 'minitest/autorun'
require 'mysql_cli'

class MysqlCliTest < MiniTest::Unit::TestCase
  TEST_ROOT=Pathname.new(__FILE__).dirname

  def setup
    @cli = MysqlCli.new
    @cli.read_credentials_from_config(TEST_ROOT.join('database.yml'))
  end



  class Credentials < self
    def test_credentials_can_bet_set
      credentials = { host: '127.0.0.1', user: 'root' }
      @cli.credentials = credentials
      assert_equal credentials, @cli.credentials
    end

    def test_read_credentials_from_config
      refute @cli.credentials.values_at(:host, :username).include?(nil)
    end
  end



  class Sql < self
    def test_sql_string
      expected = "mysql -e 'USE application_development; show databases' -h '127.0.0.1' -u 'root'"
      assert_equal expected, @cli.sql('show databases')
    end

    def test_sql_file
      path = TEST_ROOT.join('dump.sql').to_s
      expected = "mysql -h '127.0.0.1' -u 'root' application_development < '#{path}'"
      assert_equal expected, @cli.sql(File.new path)
    end

    def test_gzipped_sql_file
      path = TEST_ROOT.join('dump.sql.gz').to_s
      expected = "gunzip < '#{path}' | mysql -h '127.0.0.1' -u 'root' application_development"
      assert_equal expected, @cli.sql(File.new path)
    end
  end
end
