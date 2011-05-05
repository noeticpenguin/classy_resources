module ClassyResources
  module DataMapper
    def load_collection(resource)
      class_for(resource).all
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
      app.error ::DME::RecordNotFound do
        response.status = 404
      end
    end
  end
end

Sinatra.helpers ClassyResources::DataMapper
