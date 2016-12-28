module Documents
  class ItemProfile
    attr_reader :name, :unit, :item

    def initialize(item, config)
      @item = item
      item['upc'] ||= item['sku']
      @config = config
      @unit = config['business_unit']
      @name = "#{@unit}_ItemProfile_#{item['sku']}_#{date_stamp}.xml"
    end

    def to_xml
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.ItemProfileDocument('xmlns' => 'http://schemas.quietlogistics.com/V2/ItemProfile.xsd') {
          xml.ItemProfile('ClientID' => @config['client_id'],
            'BusinessUnit' => @unit,
            'ItemNo' => item['sku'],
            'StockWgt' => "1.0000",
            'StockUOM' => "EA",
            'ImageUrl' => image_url,
            'ItemSize' => item['item_size'],
            'ItemMaterial' => item['material'],
            'ItemColor' => color,
            'ItemDesc' => item_desc,
            'CommodityClass' => item['commodity_class'],
            'CommodityDesc' => item_desc,
            'UPCno' => item['upc'],
            'VendorName' => brand,
            'VendorItemNo' => item['vendor_item_no']) {
              xml.UnitQuantity('BarCode' => item['upc'], 'Quantity' => '1', 'UnitOfMeasure' => 'EA')
            }
        }
      end
      builder.to_xml
    end

    def item_desc
      [brand, item["name"], options].compact.join(" / ")
    end

    def options
      item["options"].map{|k,v| [k,v].join(": ")}.join(" ") if item["options"]
    end

    def brand
      Hash[item["taxons"].map{|a| [a.first, a.last]}]["Brand"]
    end

    def color
      item["options"]["Color"]
    end

    def image_url
      item["images"].first["url"] if item["images"].any?
    end

    def date_stamp
      @date_stamp ||= Time.now.strftime('%Y%m%d_%H%M%3N')
    end

    def message
      "ItemProfile Document Successfuly Sent:\n#{to_xml}"
    end
  end
end
