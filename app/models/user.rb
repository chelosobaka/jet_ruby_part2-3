class User < ApplicationRecord
  mount_uploader :avatar, AvatarUploader

  has_many :orders, dependent: :destroy
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates_presence_of :first_name, :second_name, :patronymic, :phone_number, :email
  validates :phone_number, numericality: true, length: { minimum: 10, maximum: 15 }
end
