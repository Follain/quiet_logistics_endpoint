module Documents
  class PurchaseOrderReceipt
    attr_reader :type

    def initialize(xml,name)
     
      @doc_name = name
      @doc = Nokogiri::XML(xml).remove_namespaces!
      @type = :purchase_order
      @business_unit = @doc.xpath("//@BusinessUnit").first.text
      @po_number = @doc.xpath("//@PONumber").first.value
    end

    def to_h
      {
        doc_name: @doc_name,
        id: @po_number,
        status: 'received',
        business_unit: @business_unit,
        line_items: assemble_items,
      }
    end

    private

    def assemble_items
      @doc.xpath('//PoLine').collect { |child|
          { line_number: child['Line'],
            itemno: child['ItemNumber'],
            quantity: child['ReceiveQuantity'],
            receivedate: child['ReceiveDate'] } }
    end
  end
end