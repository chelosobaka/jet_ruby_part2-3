require 'rails_helper'

RSpec.describe Order, type: :model do
  subject(:order) { described_class.new }
  let(:user) do
    User.create(
      first_name: 'Test',
      second_name: 'Test',
      patronymic: 'Test',
      phone_number: '1234567890',
      email: 'test@mail.ru',
      password: '123456',
      password_confirmation: '123456'
    )
  end

  %w[origins destinations].each do |point|
    describe "##{point}=" do
      it 'convert coordinates to correct form' do
        order.send "#{point}=", '   23.12,23.23   '
        order.send "process_#{point}"
        expect(order.send(point.to_s)).to eq('23.12, 23.23')
      end

      it 'convert addres to coordinates' do
        order.send "#{point}=", 'Moscow, Russia'
        order.send "process_#{point}"
        expect(order.send(point.to_s)).to eq('55.7504461, 37.6174943')
      end

      it 'return error' do
        order.send "#{point}=", 'Moscow, Russia'
        allow(order).to receive(:get_coordinates).and_raise(StandardError)
        expect { order.send("process_#{point}") }.to raise_error(StandardError)
      end
    end
  end

  describe '#calc_distance' do
    let(:moscow_location) { '55.7504461, 37.6174943' }
    let(:paris_location) { '48.8588897, 2.3200410217200766' }

    it 'calc distance between Moscow and Paris' do
      order.origins = moscow_location
      order.destinations = paris_location
      expect(order.send(:calc_distance)).to eq(2_856_336)
    end

    it 'return error' do
      order.destinations = paris_location
      expect { order.send(:calc_distance) }.to raise_error(StandardError)
    end

    it 'anomaly betwen Russia and France' do
      order.origins = '64.6863136, 97.7453061'
      order.destinations = '46.603354, 1.8883335'
      expect { order.send(:calc_distance) }.to raise_error(StandardError)
    end
  end

  describe '#volume' do
    it 'calc volume (cm to m)' do
      order.width = 10
      order.length = 20
      order.height = 30
      expect(order.send(:volume)).to eq(0.006)
    end

    it 'return error' do
      order.width = 10
      order.length = nil
      order.height = 30
      expect { order.send(:calc_distance) }.to raise_error(StandardError)
    end
  end

  describe '#calc_price' do
    it 'volume less or eq 1' do
      allow(order).to receive(:volume).and_return(1)
      distance = 1000
      expect(order.send(:calc_price, distance)).to eq(1.0)
    end

    it 'volume great then 1 and weight less or eq 10' do
      allow(order).to receive(:volume).and_return(2)
      order.weight = 10
      distance = 1000
      expect(order.send(:calc_price, distance)).to eq(2.0)
    end

    it 'volume great than 1 and weight greater than 10' do
      allow(order).to receive(:volume).and_return(2)
      order.weight = 15
      distance = 1000
      expect(order.send(:calc_price, distance)).to eq(3.0)
    end

    it 'return error' do
      allow(order).to receive(:volume).and_raise(StandardError)
      distance = 1000
      expect { order.send(:calc_price, distance) }.to raise_error(StandardError)
    end
  end

  describe '#calc_order' do
    it 'return correct hash' do
      allow(order).to receive(:calc_distance).and_return(1000)
      allow(order).to receive(:calc_price).and_return(10.35)

      order.send('calc_order')
      expect(order.send(:distance)).to eq(1000)
      expect(order.send(:price)).to eq(10.35)
    end

    it 'return error' do
      allow(order).to receive(:calc_distance).and_raise(StandardError)
      expect { order.calc_order }.to raise_error(StandardError)
    end
  end

  describe '#coordinates?' do
    ['23.12, 23.23', '-23.12, -23.23', '23.12,23.23', '23.12,23.23'].each do |value|
      it { expect(order.send(:coordinates?, value)).to be true }
    end

    it { expect(order.send(:coordinates?, '23.12 23.23')).to be false }
  end

  describe '#get_coordinates' do
    ['moscow, russia', ' Москва Россия   ', 'Russia    москва'].each do |location|
      it { expect(order.send(:get_coordinates, location)).to eq('55.7504461, 37.6174943') }
    end

    it { expect { order.send(:get_coordinates, 'fgsd323ffs') }.to raise_error(StandardError) }
  end

  it 'must create order' do
    order = described_class.new(user_id: user.id, weight: 0.11, length: 0.22, width: 0.33, height: 0.44,
                                origins: 'moscow, russia', destinations: 'france, paris')
    expect { order.save }.to change(described_class, :count).by(1)
  end

  describe 'aasm' do
    let(:order) do
      described_class.create(user_id: user.id, weight: 0.11, length: 0.22, width: 0.33, height: 0.44,
                             origins: 'moscow, russia', destinations: 'france, paris')
    end

    it 'initial state should be processing' do
      expect(order).to have_state(:processing)
    end

    it 'transitions from processing to completing on complete event' do
      expect(order).to transition_from(:processing).to(:completing).on_event(:complete)
    end
  end
end
