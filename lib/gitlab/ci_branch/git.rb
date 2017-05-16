
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

      def find_by(name)
        puts @branches.inspect
        needle = name.include?('/') ? name : "/#{name}"
        find { |branch| branch.end_with?(needle) }
      end

      private

      def remote_branches
        `git branch --list --remotes | grep -v ' -> '`.split("\n").map(&:strip)
      end
    end

    class GitDistance
      def initialize
        @current_sha ||= ENV['CI_COMMIT_SHA'] || `git rev-parse HEAD`.strip
      end

      def from(branch)
        `git rev-list --boundary #{@current_sha}...#{branch} | wc -l`.strip
      end
    end
  end
end
