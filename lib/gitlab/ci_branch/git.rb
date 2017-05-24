
module Gitlab
  module CiBranch
    class GitBranch
      include Enumerable

      def initialize(branches = nil)
        @branches = branches || remote_branches
      end

      def each
        @branches.each { |branch| yield branch }
      end

      def find_by(branches = [])
        Array(branches).map do |branch_name|
          branch_needle = branch_name.include?('/') ? name : "/#{branch_name}"
          select { |branch| branch =~ %r{#{branch_needle}} }
        end.flatten.compact
      end

      private

      def remote_branches
        `git branch --list --remotes | grep -v ' -> '`.split("\n").map(&:strip)
      end
    end

    class GitDistance
      LARGE_NUMBER = 1_000_000
      def initialize
        @current_sha ||= ENV['CI_COMMIT_SHA'] || `git rev-parse HEAD`.strip
      end

      def from(branch)
        distance = `git rev-list --boundary #{@current_sha}...#{branch} | wc -l`.strip
        distance.empty? ? LARGE_NUMBER : distance.to_i
      end
    end
  end
end
