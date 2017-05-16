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
        merge_requests.select { |merge_request| merge_request.source_branch == current_branch}
      end

      def merge_requests
        @gitlab.merge_requests(@project_id, { state: 'opened' })
      end

      private

      def current_branch
        @current_branch ||= ENV['CI_COMMIT_REF_NAME'] || `git rev-parse --abbrev-ref HEAD`.strip
      end
    end
  end
end
