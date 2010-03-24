require 'rubygems'
require 'test/unit'
require 'context'
require 'zebra'
require 'mocha'
require 'rack/test'
require File.dirname(__FILE__) + '/../lib/classy_resources'

class Test::Unit::TestCase
  include Rack::Test::Methods

  protected
    def create_post(opts = {})
      Post.create!({:title => 'awesome'}.merge(opts))
    end

    def hash_for_comment(opts = {})
      {}.merge(opts)
    end

    def create_comment(opts = {})
      Comment.create!(hash_for_comment(opts))
    end

    def create_user(opts = {})
      u = User.new({:name => 'james'}.merge(opts))
      u.save
      u
    end

    def hash_for_subscription(opts = {})
      {:name => "emptiness is depressing"}.merge(opts)
    end

    def create_subscription(opts = {})
      s = Subscription.new(hash_for_subscription(opts))
      s.save
      s
    end
end
