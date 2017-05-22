require 'gitlab'

module Gitlab
  module CiBranch
    class MergeRequests
      def initialize(project_id: nil, gitlab: Gitlab)
        @gitlab = gitlab
        @project_id = project_id || ENV['CI_PROJECT_ID']
      end

      def target_branches
        merge_results.map(&:target_branch)
      end

      def merge_results
        merge_requests.select { |merge_request| merge_request.sha == current_sha}
      end

      def merge_requests
        @gitlab.merge_requests(@project_id, { state: 'opened' })
      end

      private

      def current_sha
        @current_sha ||= ENV['CI_COMMIT_SHA'] || `git rev-parse HEAD`.strip
      end
    end
  end
end
