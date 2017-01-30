module Documents
  class ProductConfigurationRequest
    attr_reader :id, :sku

    def initialize(attributes)
      @id = attributes[:id]
      @sku = attributes[:document_name]
    end

    def to_h
      { id: id, sku: sku }
    end

    def type
      :product_configuration_request
    end
  end
end
