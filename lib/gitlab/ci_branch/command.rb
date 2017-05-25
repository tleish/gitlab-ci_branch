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
          default_branches: 'master',
          api_endpoint: guess_api_endpoint,
          api_private_token: guess_api_private_token,
          api_project_id: guess_api_project_id,
        }
        @git_branch = Gitlab::CiBranch::GitBranch.new
      end

      def self.execute
        cmd = self.new
        cmd.setup
        cmd.run
      end

      def run
        branches = []
        branches += target_branches
        branches += nearest if branches.empty?
        output = branches.uniq.join(',')
        puts branches.uniq.join(',')
        output
      end

      def setup
        parse_options
        validate_api_config
        Gitlab.configure do |config|
          config.endpoint = @options[:api_endpoint] if @options[:api_endpoint]
          config.private_token = @options[:api_private_token] if @options[:api_private_token]
        end
      end

      private

      def validate_api_config
        [:api_endpoint, :api_private_token, :api_project_id].each do |option|
          next unless @options[option].to_s.empty?
          puts "Error: #{option} is not defined. See README."
          exit
        end
        return unless @options[:api_endpoint].to_s.empty? || @options[:api_private_token].to_s.empty?
      end

      def parse_options
        OptionParser.new do |opts|
          opts.banner = 'Usage: gitlab-ci-branch [options]'

          default_branches_desc = 'Comma seperated list of branches to fallback to if there are no merge requests. ' +
                                  'This tool will try and determine the closest single branch and use it for comparison. ' +
                                  '(Optional, Default = master)'

          opts.on('-d', '--default_branches=branches', default_branches_desc) do |v|
            @options[:default_branches] = v
          end

          opts.on('--api_endpoint=url', 'Gitlab API Endpoint (optional)') do |v|
            @options[:api_endpoint] = v
          end

          opts.on('--api_private_token=token', 'Gitlab API Token (optional)') do |v|
            @options[:api_private_token] = v
          end

          opts.on('--api_project_id=id', 'Gitlab API Project ID (optional)') do |v|
            @options[:api_project_id] = v
          end

        end.parse!
      end

      def nearest
        return [] if @options[:default_branches].empty?
        branches = @git_branch.find_by(@options[:default_branches].split(',').map(&:strip))
        git_distance = Gitlab::CiBranch::GitDistance.new
        Gitlab::CiBranch::Nearest.new(branches, git_distance).branch
      end

      def target_branches
        branches = Gitlab::CiBranch::MergeRequests.new(project_id: @options[:api_project_id]).target_branches
        branches.map! { |branch| "/#{branch}$" }
        @git_branch.find_by(branches)
      end

      def guess_api_endpoint
        pronto['api_endpoint'] || ENV['GITLAB_API_ENDPOINT'] || api_from_ci_project_url
      end

      def api_from_ci_project_url
        ENV['CI_PROJECT_URL'].to_s.sub(ENV['CI_PROJECT_PATH'].to_s, "api/#{API_VERSION}")
      end

      def guess_api_private_token
        pronto['api_private_token'] || ENV['GITLAB_API_PRIVATE_TOKEN']
      end

      def guess_api_project_id
        ENV['CI_PROJECT_ID'] || pronto['slug']
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
