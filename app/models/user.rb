class User < ApplicationRecord
  # Devise modules: add :confirmable, :lockable, :timeoutable, :trackable, :omniauthable if needed
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy

  validates :name, presence: true
end
