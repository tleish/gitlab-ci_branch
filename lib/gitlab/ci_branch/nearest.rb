
module Gitlab
  module CiBranch
    class Nearest
      VERY_BIG_NUMBER = 1_000_000

      def initialize(branches, git = Git)
        @git = git.new
        @branches = valid(branches)
      end

      def branch
        nearest = commit_counts.min_by { |_, commit_count| commit_count }
        nearest ? [nearest.first] : []
      end

      private

      def commit_counts
        @commit_counts ||= begin
          counts = {}
          @branches.map do |branch|
            counts[branch] = @git.commit_count(branch)
          end
          counts
        end
      end

      def valid(requested_branches)
        all_branches = @git.branches
        requested_branches.map { |branch| all_branches.grep %r{/#{branch}$} }.flatten!.compact
      end
    end

    class Git
      def branches
        @branches ||= `git branch -a`.split("\n").map(&:strip)
      end

      def commit_count(branch)
        `git rev-list --boundary #{current_sha}...#{branch} | wc -l`.strip
      end

      def current_sha
        @current_sha ||= ENV['CI_COMMIT_SHA'] || `git rev-parse HEAD`.strip
      end
    end
  end
end
