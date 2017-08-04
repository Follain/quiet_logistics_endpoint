module Documents
  class InventorySummary
    attr_reader :type, :doc

    def initialize(xml)
      @doc  = Nokogiri::XML(xml).remove_namespaces!
      @type = :inventory
    end

    def business_unit
      @business_unit ||= doc.xpath('//@BusinessUnit').first.value
    end

    def warehouse
      @warehouse ||= doc.xpath("//@Warehouse").first.text
    end

    def message_date
      @message_date ||= doc.xpath("//@MessageDate").first.text
    end

    def to_a
      doc.xpath("//Inventory").collect do |inventory|
        {
          id: message_date + "-" + inventory['ItemNumber'],
          location: warehouse,
          business_unit: business_unit,
          product_id: inventory['ItemNumber'],
          allocated: with_status(inventory, 'Alloc'),
          available: with_status(inventory, 'Avail'),
          damaged: with_status(inventory, 'DAM'),
          quantity: quantity(inventory),
          received: with_status(inventory, 'RECEIVED')
        }
      end
    end

    def quantity(inventory)
      with_status(inventory, 'Avail').to_i +
        with_status(inventory, 'RECEIVED').to_i
    end

    def with_status(inventory, status)
      node = inventory.xpath("ItemStatus[@Status='#{status}']").first
      node["Quantity"].to_i if node.present?
    end
  end
end
