require 'json'
require 'net/http'

class Order < ApplicationRecord
  before_validation :process_origins, :process_destinations

  validates_presence_of :weight, :length, :width, :height, :origins, :destinations
  validates_presence_of :first_name, :second_name, :patronymic, :phone_number, :email
  validates :weight, :length, :width, :height, comparison: { greater_than: 0 }
  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }
  validates :phone_number, numericality: true, length: { minimum: 10, maximum: 15 }

  after_validation :calc_order

  def self.ransackable_attributes(auth_object = nil)
    %w[id first_name second_name patronymic phone_number email weight width length height
       origins destinations distance price created_at updated_at]
  end

  private

  def process_origins
    self.origins = if coordinates?(origins)
                     origins.gsub(/\s+/, '').gsub(/,/, ', ')
                   else
                     get_coordinates(origins)
                   end
  rescue StandardError => e
    add_error("Couldn't process origins: #{e}")
  end

  def process_destinations
    self.destinations = if coordinates?(destinations)
                          destinations.gsub(/\s+/, '').gsub(/,/, ', ')
                        else
                          get_coordinates(destinations)
                        end
  rescue StandardError => e
    add_error("Couldn't process destinations: #{e}")
  end

  def calc_order
    self.distance = calc_distance
    self.price = calc_price(distance).round(2, half: :up)
  rescue StandardError => e
    add_error("Couldn't calculate order: #{e}")
  end

  def distancematrix_path
    'https://api-v2.distancematrix.ai/maps/api/distancematrix/json?'\
    "origins=#{origins.gsub(/\s+/, '')}&"\
    "destinations=#{destinations.gsub(/\s+/, '')}&key=#{Rails.application.credentials.api.distancematrix_api_key}"
  end

  # return value in meters
  def calc_distance
    url = URI.parse(URI::Parser.new.escape(distancematrix_path))
    response = JSON.parse(Net::HTTP.get(url))
    distance = response.dig('rows', 0, 'elements', 0, 'distance', 'value')
    distance.positive? ? distance : raise(StandardError)
  rescue StandardError => e
    add_error("Couldn't calculate distance: #{e}")
  end

  def calc_price(distance)
    if volume <= 1
      distance / 1000.0
    elsif weight <= 10
      2 * distance / 1000.0
    else
      3 * distance / 1000.0
    end
  rescue StandardError => e
    add_error("Couldn't calculate price: #{e}")
  end

  # return value in meters
  def volume
    (width.to_f * length.to_f * height.to_f) / 1_000_000.0
  rescue StandardError => e
    add_error("Couldn't calculate volume: #{e}")
  end

  def coordinates?(value)
    /^[-+]?\d+\.\d+,\s*[-+]?\d+\.\d+$/.match?(value.strip)
  end

  def geocoder_path(address)
    "https://api-v2.distancematrix.ai/maps/api/geocode/json?address=#{address}&key=#{Rails.application.credentials.api.geocoder_api_key}"
  end

  def get_coordinates(address)
    address.strip!
    address = address.gsub(/\s+/, '+') || address
    url = URI.parse(URI::Parser.new.escape(geocoder_path(address)))
    response = JSON.parse(Net::HTTP.get(url))
    location = response.dig('result', 0, 'geometry', 'location') || raise(StandardError)

    "#{location['lat']}, #{location['lng']}"
  rescue StandardError => e
    add_error("Couldn't get coordinates: #{e}")
  end

  def add_error(msg)
    errors.add(:base, msg)
    raise ActiveRecord::Rollback
  end
end
