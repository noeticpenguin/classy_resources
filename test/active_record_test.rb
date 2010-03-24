require File.dirname(__FILE__) + '/test_helper'
require File.dirname(__FILE__) + '/fixtures/active_record_test_app'

class ActiveRecordTest < Test::Unit::TestCase
  def app
    ActiveRecordTestApp
  end

  context "on GET to /posts with xml" do
    setup do
      2.times { create_post }
      get '/posts.xml'
    end

    expect { assert_equal 200, last_response.status }
    expect { assert_equal Post.all.to_xml, last_response.body }
    expect { assert_equal "application/xml", last_response.content_type }
  end

  context "on GET to /posts with json" do
    setup do
      2.times { create_post }
      get '/posts.json'
    end

    expect { assert_equal 200, last_response.status }
    expect { assert_equal Post.all.to_json, last_response.body }
    expect { assert_equal "application/json", last_response.content_type }
  end

  context "on POST to /posts" do
    setup do
      Post.destroy_all
      post '/posts.xml', :post => {:title => "whatever"}
    end

    expect { assert_equal 201, last_response.status }
    expect { assert_equal "/posts/#{Post.first.id}.xml", last_response.location }
    expect { assert_equal "whatever", Post.first.title }
    expect { assert_equal "application/xml", last_response.content_type }
    expect { assert_equal Post.first.to_xml, last_response.body }
  end

  context "on POST to /posts with invalid params" do
    setup do
      Post.destroy_all
      post '/posts.xml', :post => {}
    end

    expect { assert_equal 422, last_response.status }
    expect { assert_equal "application/xml", last_response.content_type }
    expect { assert_equal Post.create.errors.to_xml, last_response.body }
    expect { assert_equal 0, Post.count }
  end

  context "on GET to /posts/id" do
    setup do
      @post = create_post
      get "/posts/#{@post.id}.xml"
    end

    expect { assert_equal 200, last_response.status }
    expect { assert_equal @post.to_xml, last_response.body }
    expect { assert_equal "application/xml", last_response.content_type }
  end

  context "on GET to /posts/id with a missing post" do
    setup do
      get "/posts/doesntexist.xml"
    end

    expect { assert_equal 404, last_response.status }
    expect { assert last_response.body.empty? }
    expect { assert_equal "application/xml", last_response.content_type }
  end

  context "on PUT to /posts/id" do
    setup do
      @post = create_post
      put "/posts/#{@post.id}.xml", :post => {:title => "Changed!"}
    end

    expect { assert_equal 200, last_response.status }
    expect { assert_equal @post.reload.to_xml, last_response.body }
    expect { assert_equal "application/xml", last_response.content_type }

    should "update the post" do
      assert_equal "Changed!", @post.reload.title
    end
  end

  context "on PUT to /posts/id with invalid params" do
    setup do
      @post = create_post
      put "/posts/#{@post.id}.xml", :post => {:title => ""}
    end

    expect { assert_equal 422, last_response.status }
    expect { assert_equal "application/xml", last_response.content_type }
    expect { assert_equal Post.create.errors.to_xml, last_response.body }

    should "not update the post" do
      assert_not_equal "", @post.reload.title
    end
  end

  context "on PUT to /posts/id with a missing post" do
    setup do
      put "/posts/missing.xml", :post => {:title => "Changed!"}
    end

    expect { File.open("/Users/rick/Desktop/error.html",'w') { |f| f << last_response.body } ; assert_equal 404, last_response.status }
    expect { assert last_response.body.empty? }
    expect { assert_equal "application/xml", last_response.content_type }
  end

  context "on DELETE to /posts/id" do
    setup do
      @post = create_post
      delete "/posts/#{@post.id}.xml"
    end

    expect { assert_equal 200, last_response.status }
    expect { assert_equal "application/xml", last_response.content_type }

    should "destroy the post" do
      assert_nil Post.find_by_id(@post)
    end
  end

  context "on DELETE to /posts/id with a missing post" do
    setup do
      delete "/posts/missing.xml"
    end

    expect { assert_equal 404, last_response.status }
    expect { assert_equal "application/xml", last_response.content_type }
    expect { assert last_response.body.empty? }
  end

  context "on POST to /comments with a JSON post body" do
    setup do
      Comment.destroy_all
      post "/comments.xml", {:comment => hash_for_comment(:author => 'james')}.to_json,
                             'CONTENT_TYPE' => 'application/json'
    end

    expect { assert_equal 201, last_response.status }
    expect { assert_equal "application/xml", last_response.content_type }
    expect { assert_equal "/comments/#{Comment.first.id}.xml", last_response.location }
    expect { assert_equal 1, Comment.count }
    expect { assert_equal 'james', Comment.first.author }
  end

  context "on POST to /posts/id/comments with a XML post body" do
    setup do
      Comment.destroy_all
      post "/comments.xml", Comment.new(:author => 'james').to_xml,
                                        'CONTENT_TYPE' => 'application/xml'
    end

    expect { assert_equal 201, last_response.status }
    expect { assert_equal "application/xml", last_response.content_type }
    expect { assert_equal "/comments/#{Comment.first.id}.xml", last_response.location }
    expect { assert_equal 1, Comment.count }
    expect { assert_equal 'james', Comment.first.author }
  end
end
