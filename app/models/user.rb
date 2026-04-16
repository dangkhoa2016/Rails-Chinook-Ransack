class User < ApplicationRecord
  ROLES = %w[admin user].freeze

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable, :lockable

  validates :role, inclusion: { in: ROLES }
  validates :name, presence: true, length: { maximum: 100 }

  def admin?
    role == "admin"
  end

  def user?
    role == "user"
  end

  def display_name
    name.presence || email
  end
end
