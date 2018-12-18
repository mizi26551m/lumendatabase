require 'validates_automatically'

class TokenUrl < ActiveRecord::Base
  include ValidatesAutomatically

  before_create :generate_token

  belongs_to :user
  belongs_to :notice

  validates :email,
            allow_blank: true,
            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :notice, presence: true

  def self.valid?(token, notice)
    token_url = TokenUrl.find_by(token: token)

    valid_token_url_and_notice?(token_url, notice) &&
      valid_time?(token_url) &&
      token_url.notice == notice
  end

  def self.valid_time?(token_url)
    token_url[:valid_forever] ||
      token_url[:expiration_date].nil? ||
      (!token_url[:expiration_date].nil? &&
      token_url[:expiration_date] > Time.now)
  end

  def self.valid_token_and_notice?(token_url, notice)
    !token_url.nil? && !notice.nil?
  end

  private

  def generate_token
    self.token = loop do
      random_token = SecureRandom.urlsafe_base64(nil, false)
      break random_token unless TokenUrl.exists?(token: random_token)
    end
  end
end