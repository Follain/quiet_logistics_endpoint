
module Documents
  class InventorySummaryRequest
    attr_reader :name

    def initialize(config)
      @config = config
      @unit   = config['business_unit']
      @name = "#{@unit}_InventorySummaryRequest_#{date_stamp}.xml"
    end

    def to_xml
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.InventorySummaryRequest(
          'xmlns' => 'http://schemas.quietlogistics.com/V2/InventorySummaryRequest.xsd',
          'ClientID' => @config['client_id'],
          'BusinessUnit' => @unit
        )
      end

      builder.to_xml
    end

    def date_stamp
      @date_stamp ||= Time.now.strftime('%Y%m%d_%H%M%3N')
    end

    def message
      "InventorySummaryRequest Document Successfuly Sent:\n#{to_xml}"
    end
  end
end
