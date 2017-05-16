require 'ostruct'
require_relative '../../test_helper'
require File.join(ROOT_APP_PATH, 'lib/gitlab/ci_branch/git')

describe Gitlab::CiBranch::GitBranch do
  it "Can find a branch by a subname" do
    branches = ['origin/develop', 'origin/master', 'origin/other']
    git_branch = Gitlab::CiBranch::GitBranch.new(branches)
    git_branch.find_by('master').must_equal 'origin/master'
  end
end

