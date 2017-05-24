require_relative 'git'

module Gitlab
  module CiBranch
    class Nearest
      MAX_COMMITS = 500

      def initialize(branches, git_distance)
        @branches = branches
        @git_distance = git_distance
      end

      def branch
        nearest = distances.select { |_, commit_count| commit_count <= MAX_COMMITS } .
                            min_by { |_, commit_count| commit_count }
        nearest ? [nearest.first] : []
      end

      private

      def distances
        @distances ||= begin
          counts = {}
          @branches.map do |branch|
            counts[branch] = @git_distance.from(branch)
          end
          counts
        end
      end
    end
  end
end
