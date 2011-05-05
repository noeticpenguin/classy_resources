require 'dm-core'
require 'json'
require 'dm-serializer'
module ClassyResources
  module DataMapper
    def load_collection(resource, params = nil)
      if params.nil?
        class_for(resource).all.to_json
      else
        finder_method = "find_by_" + params.keys.join("_and_")
        class_for(resource).send(finder_method, params.values).to_json
      end
    end

    def build_object(resource, object_params)
      class_for(resource).new(object_params)
    end

    def load_object(resource, id)
      class_for(resource).find(id)
    end

    def update_object(object, params)
      object.attributes = params
    end

    def destroy_object(object)
      object.destroy
    end

    def self.included(app)
      app.error ::DataMapper::ObjectNotFoundError do
        response.status = 404
      end
    end
  end
end

Sinatra.helpers ClassyResources::DataMapper
