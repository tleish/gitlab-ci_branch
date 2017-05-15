$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'gitlab/ci_branch'
require 'minitest/autorun'
require 'minitest/pride'
require 'minitest/spec'
require 'minitest/reporters'
Minitest::Reporters.use!

ROOT_APP_PATH = File.expand_path(File.join(File.dirname(__FILE__), '../'))
