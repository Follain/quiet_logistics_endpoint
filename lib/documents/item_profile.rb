module Documents
  class ItemProfile
    attr_reader :name, :unit, :item

    def initialize(item, config)
      @item = item
      @config = config
      @unit = config['business_unit']
      @name = '#{@unit}_ItemProfile_#{item["sku"]}_#{date_stamp}.xml'
    end

    def to_xml
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.ItemProfileDocument('xmlns' => 'http://schemas.quietlogistics.com/V2/ItemProfile.xsd') {
          xml.ItemProfile('ClientID' => @config['client_id'],
            'BusinessUnit' => @unit,
            'ItemNo' => item['sku'],
            'StockWgt' => '1.0000',
            'StockUOM' => 'EA',
            'ImageUrl' => image_url,
            'ItemSize' => item['item_size'],
            'ItemMaterial' => item['material'],
            'ItemColor' => color,
            'ItemDesc' => item_desc,
            'CommodityClass' => item['commodity_class'],
            'CommodityDesc' => item_desc,
            'UPCno' => item['sku'],
            'VendorName' => item['brand'],
            'VendorItemNo' => item['vendor_item_no']) {
              xml.UnitQuantity('BarCode' => item['sku'], 'Quantity' => '1', 'UnitOfMeasure' => 'EA')
            }
        }
      end
      builder.to_xml
    end

    def item_desc
      [item['name'], options].compact.join(' / ')
    end

    def options
      item['options_value']
    end

    def color
      if item['option_value'] !='def'
         item['option_value']
      end
    end

    def image_url
      item['image']
    end

    def date_stamp
      @date_stamp ||= Time.now.strftime('%Y%m%d_%H%M%3N')
    end

    def message
      'ItemProfile Document Successfuly Sent:\n#{to_xml}'
    end
  end
end
