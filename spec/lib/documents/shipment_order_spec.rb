# frozen_string_literal: true
require 'spec_helper'

module Documents
  describe ShipmentOrder do
    let(:shipment) { Factories.shipment }
    let(:xml) { Nokogiri::XML subject.to_xml }
    let(:xsd) do
      Nokogiri::XML::Schema File.read('./spec/schemas/shipment_order.xsd')
    end

    subject { ShipmentOrder.new(shipment, {}) }

    it 'converts to xml' do
      errors = xsd.validate(xml).collect { |error| error }

      expect(subject.name).to match(/^_ShipmentOrder_#{shipment['id']}_.*\.xml/)
      expect(errors).to eq []

      expect(xml.css('Gift')).to be_empty
    end

    context 'when shipment contains comments' do
      before { shipment['comments'] = 'Happy Birthday' }

      it 'sets <Comments> correctly' do
        expect(xml.css('Comments').size).to eq 1
        expect(xml.css('Comments').first.to_s)
          .to eq '<Comments>Happy Birthday</Comments>'
      end
    end

    context 'when shipment[gift] is true' do
      before { shipment['gift'] = true }

      it 'sets <OrderHeader Gift="true">' do
        header = xml.css('OrderHeader').first
        expect(header['Gift']).to eq 'true'
      end
    end
  end
end
