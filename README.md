# Gitlab::CiBranch

Prints comma seperated list of branches to use for Gitlab CI in order to determine which branches have merge requests against them.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'gitlab-ci_branch'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install gitlab-ci_branch

## Usage

Run gem via command line:

```
gitlab-ci-branch [options]

```

## Options

* -d, --default_branches=branches  
  Comma seperated list of branches to fallback to if there are no merge requests. This tool will try and determine the closest single branch and use it for comparison. (Optional, default = master)
*  --api_endpoint=url
  Gitlab API Endpoint (optional)
* --api_private_token=token
  Gitlab API Token (optional)
* --api_project_id=id
  Gitlab API Project ID (optional)

## Example

```
$ gitlab-ci-branch --default_branches=develop,master
=> origin/master,origin/develop

```

## No Merge Branches

If no merge branches are found, then it will return 'master' or another closer branch as specified by the --default_branches option.

## API Credentials

API credentials must be defined in order to access Gitlabs API.  They can be defined in 1 of 3 ways.

### Options 

(see options)

### Pronto Config

If a .pronto.yml config file is in the root of the project and has Gitlab API parameters, this gem will use those parameters instead of Gitlab API flags passed into the tool

.pronto.yml Example:
```
gitlab:
  slug: 1234567 # gitlab's project ID
  api_private_token: 46751
  api_endpoint: https://api.vinted.com/gitlab
```
see: https://github.com/prontolabs/pronto 

### Environment Variables

```
export GITLAB_API_ENDPOINT=https://api.vinted.com/gitlab
export GITLAB_API_PRIVATE_TOKEN=https://api.vinted.com/gitlab
```

Note: Both api_endpoint and api_project_id can sometimes be guessed using Gitlabs CI environment variables and therefore sometimes are not needed.


## .gitlab-ci.yml Example

```
before_script:
  - echo 'gem "gitlab-ci_branch", :git => "https://github.com/tleish/gitlab-ci_branch.git", :group => :development' >> Gemfile
  - bundle install
  - export BRANCHES=$(bundle exec gitlab-ci-branch --default_branches=develop,master)
  - echo $BRANCHES

brakeman:
  script:
    - for branch in ${BRANCHES//,/ }; do echo $branch; pronto run --formatters=gitlab text --commit="$branch" --runner=brakeman --exit-code; done
```
