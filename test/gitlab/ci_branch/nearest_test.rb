require 'ostruct'
require_relative '../../test_helper'
require File.join(ROOT_APP_PATH, 'lib/gitlab/ci_branch/nearest')


describe Gitlab::CiBranch::Nearest do
  it "Returns the closest branch from a list" do
    branches = ['origin/develop', 'origin/master', 'origin/other']
    merge_requests = Gitlab::CiBranch::Nearest.new(branches, GitDistanceMock.new)
    merge_requests.branch.must_equal ['origin/master']
  end

  it "Only includes branches with less than 50 commits" do
    branches = ['origin/develop', 'origin/master', 'origin/other']
    merge_requests = Gitlab::CiBranch::Nearest.new(branches, GitDistanceMock.new(60, 100))
    merge_requests.branch.must_equal []
  end
end

class GitDistanceMock
  def initialize(master_length = 10, other_length = 40)
    @master_length = master_length
    @other_length = other_length
  end

  def from(branch)
    branch == 'origin/master' ? @master_length : @other_length
  end
end
