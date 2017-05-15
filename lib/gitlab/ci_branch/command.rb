require 'gitlab'
require 'pronto'
require_relative 'nearest'
require_relative 'merge_requests'

module Gitlab
  module CiBranch
    class Command

      API_VERSION = 'v4'
      PRONTO_FILE = '.pronto.yml'

      def initialize
        @options = {
          merge_requests: false,
          closest_to: [],
          api_endpoint: guess_api_endpoint,
          api_private_token: guess_api_private_token,
        }

      end

      def self.execute
        cmd = self.new
        cmd.parse_options
        cmd.setup
        cmd.run
      end

      def run
        branches = []
        branches += Gitlab::CiBranch::MergeRequests.new.target_branches if @options[:merge_requests]
        branches += Gitlab::CiBranch::Nearest.new(@options[:closest_to]).branch unless @options[:closest_to].empty?
        puts branches.uniq.join(',')
      end

      def setup
        Gitlab.configure do |config|
          config.endpoint = @options[:api_endpoint] if @options[:api_endpoint]
          config.private_token = @options[:api_private_token] if @options[:api_private_token]
        end
      end

      def parse_options
        OptionParser.new do |opts|
          opts.banner = 'Usage: example.rb [options]'

          opts.on('--api_endpoint=url', 'Gitlab API Endpoint') do |v|
            @options[:api_endpoint] = v
          end

          opts.on('--api_private_token=token', 'Gitlab API Token') do |v|
            @options[:api_private_token] = v
          end

          opts.on('-m', '--merge_requests', 'Return Branches for All Merge Requests') do
            @options[:merge_requests] = true
          end

          opts.on('-c', '--closest_to=comma,seperated,branch,list', 'Return single closest branch from list') do |v|
            @options[:closest_to] = v.split(',').map(&:strip)
          end

        end.parse!
      end

      private

      def guess_api_endpoint
        pronto['api_endpoint'] || ENV['GITLAB_API_ENDPOINT'] || api_from_ci_project_url
      end

      def api_from_ci_project_url
        ENV['CI_PROJECT_URL'].to_s.sub(ENV['CI_PROJECT_PATH'].to_s, "api/#{API_VERSION}")
      end

      def guess_api_private_token
        pronto['api_private_token'] || ENV['GITLAB_API_PRIVATE_TOKEN']
      end

      def pronto
        @pronto ||= begin
          return {} unless File.exists? PRONTO_FILE
          pronto = Pronto::ConfigFile.new(PRONTO_FILE)
          pronto.to_h['gitlab']
        end
      end

    end
  end
end
