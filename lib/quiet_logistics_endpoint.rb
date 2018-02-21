require 'aws'
require 'sinatra'
require 'nokogiri'
require 'endpoint_base'

Dir[File.dirname(__FILE__) + '/../lib/**/*.rb'].each { |f| require f }

class QuietLogisticsEndpoint < EndpointBase::Sinatra::Base
  set :logging, true

  before do
    if request.request_method == 'POST'
      AWS.config(access_key_id: @config['amazon_access_key'],
                 secret_access_key: @config['amazon_secret_key'])
    end
  end

  def result(code, message)
    puts message
    super
  end

  def add_object(key, value)
    value['channel'] = 'Quiet' if value.is_a? Hash

    super
  end

  post '/get_messages' do
    begin
      queue = @config['ql_incoming_queue']

      receiver = Receiver.new(queue)
      receiver.receive_messages { |msg| add_object :message, msg }

      message = "recevied #{receiver.count} messages"

      add_value 'messages', [] if receiver.count < 1
      code     = 200
    rescue StandardError => e
      message  = e.message
      code     = 500
    end

    result code, message
  end

  post '/get_data' do
    begin
      bucket = @config['ql_incoming_bucket']
      msg    = @payload['message']
      data   = Processor.new(bucket).process_doc(msg)

      if data.type == :unknown
        message = "Cannot handle document of type #{msg['document_type']}"
      elsif data.type == :error
        message = "Error document: #{msg}"
      else
        if data.respond_to?(:to_a)
          data.to_a.each do |h|
            add_object(data.type.to_sym, h)
          end
        else
          add_object(data.type.to_sym, data.to_h)
        end

        message = "Got Data for #{msg['document_name']}"
      end

      code = 200
    rescue StandardError => e
      message  = e.message
      code     = 500
    end

    result code, message
  end

  post '/add_shipment' do
    begin
      shipment = @payload['shipment']
      message  = Api.send_document('ShipmentOrder', shipment, outgoing_bucket, outgoing_queue, @config)
      code     = 200
    rescue StandardError => e
      message = e.message
      code    = 500
    end

    result code, message
  end

  post '/add_purchase_order' do
    begin
      order = if @payload['transfer_order'].present?
                @payload['transfer_order']
              elsif @payload['work_order'].present?
                @payload['work_order']
              else
                @payload['purchase_order']
        end
      message = Api.send_document('PurchaseOrder', order, outgoing_bucket, outgoing_queue, @config)
      code    = 200
    rescue StandardError => e
      message = e.message
      code    = 500
    end

    result code, message
  end

  post '/add_product' do
    begin
      item    = @payload['product']
      message = item['variants'].map do |variant|
        Api.send_document('ItemProfile', item.merge(variant), outgoing_bucket, outgoing_queue, @config)
      end.join("\n")
      code    = 200
    rescue StandardError => e
      message = e.message
      code    = 500
    end

    result code, message
  end

  post '/add_product_simple' do
    begin
      item = @payload['product']
      Api.send_document('ItemProfile', item, outgoing_bucket, outgoing_queue, @config)
      code    = 200
    rescue StandardError => e
      message = e.message
      code    = 500
    end

    result code, message
  end

  post '/add_rma' do
    begin
      shipment = @payload['rma']
      message  = Api.send_document('RMADocument', shipment, outgoing_bucket, outgoing_queue, @config)
      code     = 200
    rescue StandardError => e
      message  = e.message
      code     = 500
    end

    result code, message
  end

  post '/inventory_summary' do
    begin
      message  = Api.send_document('InventorySummaryRequest', nil, outgoing_bucket, outgoing_queue, @config)
      add_value 'inventory_summaries', []
      code     = 200
    rescue StandardError => e
      message  = e.message
      code     = 500
    end

    result code, message
  end

  def outgoing_queue
    @config['ql_outgoing_queue']
  end

  def outgoing_bucket
    @config['ql_outgoing_bucket']
  end
end
