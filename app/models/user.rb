class User < ApplicationRecord
  has_many :resumes, dependent: :nullify
  has_many :vacancies, dependent: :nullify

  validates :hh_id, presence: true, uniqueness: true

  scope :recent, -> { order(created_at: :desc) }

  def token_expired?
    expires_at.blank? || expires_at <= Time.current
  end

  def token_valid?
    access_token.present? && !token_expired?
  end

  def display_name
    name.presence || email.presence || "Пользователь hh.ru"
  end

  def update_tokens!(access_token:, refresh_token: nil, expires_in:)
    update!(
      access_token: access_token,
      refresh_token: refresh_token.nil? ? self.refresh_token : refresh_token,
      expires_at: Time.current + expires_in.to_i.seconds
    )
  end

  def ensure_fresh_token!
    return self if token_valid?

    raise HhRuClient::ApiError, "Refresh token missing" if refresh_token.blank?

    HhRuClient.new(user: self).refresh_access_token!
    reload
    self
  end
end
