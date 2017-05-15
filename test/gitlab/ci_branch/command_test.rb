require_relative '../../test_helper'
require File.join(ROOT_APP_PATH, 'lib/gitlab/ci_branch/command')


describe Gitlab::CiBranch::Command do
  MOCK_WORKING_DIRECTORY = File.join(ROOT_APP_PATH, 'test/mocks/')

  def setup
    ENV['CI_PROJECT_URL'] = 'https://test.gitlab.com/my/project'
    ENV['CI_PROJECT_PATH'] = 'my/project'
  end

  def teardown
    Dir.chdir ROOT_APP_PATH
    ENV['GITLAB_API_ENDPOINT'] = nil
    ENV['GITLAB_API_PRIVATE_TOKEN'] = nil
    Gitlab.endpoint = nil
    Gitlab.private_token = nil
  end

  it "Won't setup Gitlab without Pronto File or ENV variables" do
    Gitlab::CiBranch::Command.new.setup
    Gitlab.endpoint.must_equal('https://test.gitlab.com/api/v4')
    Gitlab.private_token.must_be_nil
  end

  it "Sets Gitlab variables based on ENV variables" do
    ENV['GITLAB_API_ENDPOINT'] = 'https://env.gitlab.com/api/v4'
    ENV['GITLAB_API_PRIVATE_TOKEN'] = 'api-tokennnnn'
    Gitlab::CiBranch::Command.new.setup
    Gitlab.endpoint.must_equal 'https://env.gitlab.com/api/v4'
    Gitlab.private_token.must_equal 'api-tokennnnn'
  end

  it "Sets Gitlab variables based on Pronto File" do
    Dir.chdir MOCK_WORKING_DIRECTORY
    Gitlab::CiBranch::Command.new.setup
    Gitlab.endpoint.must_equal('https://gitlab.com/api/v4')
    Gitlab.private_token.must_equal('Abc123')
  end

  it "Returns an empty string" do
    branches = Gitlab::CiBranch::Command.execute
    branches.must_equal ''
  end
end
