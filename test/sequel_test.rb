require File.dirname(__FILE__) + '/test_helper'
require 'sinatra/base'
require File.dirname(__FILE__) + '/fixtures/sequel_test_app'
require 'activesupport'

class Sequel::Model
  def to_xml(opts={})
    values.to_xml(opts)
  end
end

class SequelTest < Test::Unit::TestCase
  def app
    SequelTestApp
  end

  context "on GET to /users with xml" do
    setup do
      2.times { create_user }
      get '/users.xml'
    end

    expect { assert_equal 200, last_response.status }
    expect { assert_equal User.all.to_xml, last_response.body }
    expect { assert_equal "application/xml", last_response.content_type }
  end

  context "on POST to /users" do
    setup do
      User.destroy
      post '/users.xml', :user => {:name => "whatever"}
    end

    expect { assert_equal 201, last_response.status }
    expect { assert_equal "/users/#{User.first.id}.xml", last_response.location }
    expect { assert_equal "whatever", User.first.name }
    expect { assert_equal "application/xml", last_response.content_type }
  end

  context "on GET to /users/id" do
    setup do
      @user = create_user
      get "/users/#{@user.id}.xml"
    end

    expect { assert_equal 200, last_response.status }
    expect { assert_equal @user.to_xml, last_response.body }
    expect { assert_equal "application/xml", last_response.content_type }
  end

  context "on GET to /users/id with a missing user" do
    setup do
      get "/users/missing.xml"
    end

    expect { assert_equal 404, last_response.status }
    expect { assert last_response.body.empty? }
    expect { assert_equal "application/xml", last_response.content_type }
  end

  context "on PUT to /users/id" do
    setup do
      @user = create_user
      put "/users/#{@user.id}.xml", :user => {:name => "Changed!"}
    end

    expect { assert_equal 200, last_response.status }
    expect { assert_equal @user.reload.to_xml, last_response.body }
    expect { assert_equal "application/xml", last_response.content_type }

    should "update the user" do
      assert_equal "Changed!", @user.reload.name
    end
  end

  context "on PUT to /users/id with invalid params" do
    setup do
      @user = create_user
      put "/users/#{@user.id}.xml", :user => {:name => ""}
      @invalid_user = User.new
      @invalid_user.valid?
    end

    expect { assert_equal 422, last_response.status }
    expect { assert_equal @invalid_user.errors.to_xml, last_response.body }
    expect { assert_equal "application/xml", last_response.content_type }

    should "not update the user" do
      assert_not_equal "Changed!", @user.reload.name
    end
  end

  context "on PUT to /users/id with a missing user" do
    setup do
      put "/users/missing.xml", :user => {:name => "Changed!"}
    end

    expect { assert_equal 404, last_response.status }
    expect { assert last_response.body.empty? }
    expect { assert_equal "application/xml", last_response.content_type }
  end

  context "on DELETE to /users/id" do
    setup do
      @user = create_user
      delete "/users/#{@user.id}.xml"
    end

    expect { assert_equal 200, last_response.status }
    expect { assert_equal "application/xml", last_response.content_type }

    should "destroy the user" do
      assert_nil User.find(:id => @user.id)
    end
  end

  context "on DELETE to /users/id with a missing user" do
    setup do
      delete "/users/missing.xml"
    end

    expect { assert_equal 404, last_response.status }
    expect { assert_equal "application/xml", last_response.content_type }
    expect { assert last_response.body.empty? }
  end

  context "on POST to /subscriptions with invalid params" do
    setup do
      Subscription.destroy
      @subscription = Subscription.new
      @subscription.valid?
      post "/subscriptions.xml", :subscription => {}
    end

    expect { assert_equal 422, last_response.status }
    expect { assert_equal "application/xml", last_response.content_type }
    expect { assert_equal 0, Subscription.count }
    expect { assert_equal @subscription.errors.to_xml, last_response.body }
  end
end
