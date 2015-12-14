require 'yaml'
require_relative 'statements_dashboard'
require_relative 'raw_data_parser'

module BancoDoBrasil
  class CurrentState
    def initialize
      credentials = YAML.load_file(File.expand_path('../config/credentials.yml', __FILE__))
      @branch = credentials['branch']
      @account = credentials['account']
      @password = credentials['password']
    end

    def perform
      data = StatementsDashboard.new(@branch, @account, @password).fetch_all
      data.map do |tuple|
        uuid = save_raw(tuple)
        tuple[1]['id'] = uuid

        RawDataParser.new(*tuple).as_json
      end.flatten
    end

    private

    def save_raw(tuple)
      uuid = SecureRandom.uuid
      file_name = File.expand_path("../data/#{tuple[0]}/#{uuid}.json", __FILE__)
      folder = File.dirname(file_name)
      Dir.exist?(folder) or FileUtils.mkdir_p(folder)
      File.write(file_name, tuple[1].to_json)
      uuid
    end
  end
end
