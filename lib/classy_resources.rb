dir = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH << dir unless $LOAD_PATH.include?(dir)
require 'active_support/core_ext'
require 'classy_resources/mime_type'
require 'classy_resources/post_body_params'
require 'sinatra/base'

module ClassyResources
  module Helpers
    def class_for(resource)
      resource.to_s.singularize.classify.constantize
    end

    def collection_url_for(resource, format)
      "/#{resource}.#{format}"
    end

    def object_route_url(resource, format)
      "/#{resource}/:id.#{format}"
    end

    def object_url_for(resource, format, object)
      "/#{resource}/#{object.id}.#{format}"
    end

    def set_content_type(format)
      content_type Mime.const_get(format.to_s.upcase).to_s
    end

    def get_post_hash(body)
      case env['CONTENT_TYPE']
      when /application\/json.*/
        JSON.parse(body)
      when /application\/xml.*/
        Hash.from_xml(body)
      end
    end

    def serialize(object, format)
      object.send(:"to_#{format}")
    end
  end

  def self.registered(app)
    app.send :include, ClassyResources::Helpers
  end

  def define_resource(*options)
    ResourceBuilder.new(self, *options)
  end

  class ResourceBuilder
    include Helpers
    attr_reader :resources, :options, :app, :formats

    def initialize(app, *args)
      @app       = app
      @options   = args.pop if args.last.is_a?(Hash)
      @resources = args
      @formats   = options[:formats] || :xml

      build!
    end

    def build!
      resources.each do |r|
        [*formats].each do |f|
          [:member, :collection].each do |t|
            [*options[t]].each do |v|
              send(:"define_#{t}_#{v}", r, f) unless v.nil?
            end
          end
        end
      end
    end

    protected
      def define_collection_get(resource, format)
        app.get collection_url_for(resource, format) do
          set_content_type(format)
          serialize(load_collection(resource), format)
        end
      end
      
      def define_collection_post(resource, format)
        app.post collection_url_for(resource, format) do
          ap "got to the post method #{__LINE__}"
          set_content_type(format)
          request.body.rewind
          params = get_post_hash(request.body.read)
          params_to_send = (format =~ /application\/xml.*/) ? params[resource.to_s.singularize] : params
          object = build_object(resource, params_to_send || {})
          ap object
          if object.is_a?(resource.to_s.singularize.classify.constantize) && object.save
            response['location'] = object_url_for(resource, format, object)
            response.status      = 201
            serialize(object, format)
          else
            response.status      = 422
            serialize(object, format)
          end
        end
      end

      def define_member_get(resource, format)
        app.get object_route_url(resource, format) do
          set_content_type(format)
          object = load_object(resource, params[:id])
          serialize(object, format)
        end
      end

      def define_member_put(resource, format)
        app.put object_route_url(resource, format) do
          set_content_type(format)
          object = load_object(resource, params[:id])
          update_object(object, params[resource.to_s.singularize])

          if object.valid?
            object.save
            serialize(object, format)
          else
            response.status = 422
            serialize(object.errors, format)
          end
        end
      end

      def define_member_delete(resource, format)
        app.delete object_route_url(resource, format) do
          set_content_type(format)
          object = load_object(resource, params[:id])
          destroy_object(object)
          ""
        end
      end
  end
end

Sinatra.register ClassyResources