require 'gitlab'

module Gitlab
  module CiBranch
    class MergeRequests
      def initialize(gitlab: Gitlab)
        @gitlab = gitlab
      end

      def target_branches
        merge_results.map(&:target_branch)
      end

      def merge_results
        merge_requests.select { |merge_request| merge_request.source_branch == ENV['CI_COMMIT_REF_NAME']}
      end

      def merge_requests
        @gitlab.merge_requests(ENV['CI_PROJECT_ID'], { state: 'opened' })
      end
    end
  end
end
