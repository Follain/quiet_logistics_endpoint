class Processor

  def initialize(bucket)
    @bucket = bucket
  end

  def process_doc(msg)
    name = msg['document_name']
    type = msg['document_type']

    if %w(InventoryEventMessage ProductConfigurationRequest error).include? type
      data = msg
    else
      downloader = Downloader.new(@bucket)
      data = downloader.download(name)
    end

    # downloader.delete_file(name)

    parse_doc(type, data,name)
  end

  private

  def parse_doc(type, data,name)    
    case type
    when 'ShipmentOrderResult'
      Documents::ShipmentOrderResult.new(data)
    when 'PurchaseOrderReceipt'
      Documents::PurchaseOrderReceipt.new(data,name)
    when 'RMAResultDocument'
      Documents::RMAResult.new(data)
    when 'InventoryEventMessage'
      Documents::InventoryAdjustment.new(data)
    when 'InventorySummaryReady'
      Documents::InventorySummary.new(data)
    when 'ProductConfigurationRequest'
      Documents::ProductConfigurationRequest.new(data)
    when 'error'
      Struct.new(:type).new(:error)
    else
      Struct.new(:type).new(:unknown)
    end
  end
end
