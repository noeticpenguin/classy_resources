require 'dm-core'
require 'json'
require 'dm-serializer'
require 'dm-ar-finders'

module ClassyResources
  module DataMapper
    def load_collection(resource)
      if self.params.empty?
        class_for(resource).all
      else
        #make the param hash something datamapper can handle natively, namely a hash with symbol based keys.
        params = self.params.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo} 
        class_for(resource).all(params)
      end
    end

    def build_object(resource, object_params)
      params = self.params.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo} 
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
