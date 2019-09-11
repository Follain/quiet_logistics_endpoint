module Documents
    class CancelOrder
      attr_reader :shipment_number, :order, :shipment, :name, :unit

      def initialize(shipment, config)
        @config          = config
        @shipment        = shipment
        @shipment_number = shipment['id']
        @order_number    = shipment['order_number']
        @name            = "#{@config['business_unit']}_ShipmentOrderCancel_#{@shipment_number}_#{date_stamp}.xml"
      end

      def to_xml
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.ShipmentOrderCancel(
            'xmlns' => 'http://schemas.quietlogistics.com/V2/ShipmentOrderCancel.xsd',
            'ClientId' => @config['client_id'],
            'BusinessUnit' => @config['business_unit'],
            'OrderNumber' => @shipment_number){
            xml.Extension shipment['order_number']}
        end
        builder.to_xml
      end

      def message
        "Succesfully Sent cancellation #{@shipment_number} to Quiet Logistics"
      end

      def date_stamp
        Time.now.strftime('%Y%m%d_%H%M%3N')
      end
    end
  end
