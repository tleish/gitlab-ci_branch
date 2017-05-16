require 'ostruct'
require_relative '../../test_helper'
require File.join(ROOT_APP_PATH, 'lib/gitlab/ci_branch/nearest')


describe Gitlab::CiBranch::Nearest do
  it "Returns the closest branch from a list" do
    branches = ['origin/develop', 'origin/master', 'origin/other']
    merge_requests = Gitlab::CiBranch::Nearest.new(branches, GitDistanceMock.new)
    merge_requests.branch.must_equal ['origin/master']
  end
end

class GitDistanceMock
  def from(branch)
    branch == 'origin/master' ? 10 : 300
  end
end
