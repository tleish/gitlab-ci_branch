require 'ostruct'
require_relative '../../test_helper'
require File.join(ROOT_APP_PATH, 'lib/gitlab/ci_branch/merge_requests')


describe Gitlab::CiBranch::Command do
  MOCK_WORKING_DIRECTORY = File.join(ROOT_APP_PATH, 'test/mocks/')

  def setup
    ENV['CI_COMMIT_SHA'] = '13245'
  end

  it "Return an empty array of branches if nothing found" do
    merge_requests = Gitlab::CiBranch::MergeRequests.new(gitlab: gitlab_mock)
    merge_requests.target_branches.must_equal []
  end

  it "Return an empty array of branches" do
    merge_requests = Gitlab::CiBranch::MergeRequests.new(gitlab: gitlab_mock(ret_val_with_branches))
    merge_requests.target_branches.must_equal ['develop', 'master']
  end

  private

  def gitlab_mock(retval = [])
    mock = MiniTest::Mock.new
    mock.expect(:merge_requests, retval, [ENV['CI_PROJECT_ID'], { state: 'opened' }])
  end

  def ret_val_with_branches
    [
      OpenStruct.new(source_branch: 'other-branch', target_branch: 'other-target', sha: '654321'),
      OpenStruct.new(source_branch: 'source-branch', target_branch: 'develop', sha: '13245'),
      OpenStruct.new(source_branch: 'source-branch', target_branch: 'master', sha: '13245'),
    ]
  end


end
