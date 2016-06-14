class Invitation < ActiveRecord::Base
  belongs_to :projet
  belongs_to :operateur
  validates :projet, :operateur, presence: true
  validates_uniqueness_of :operateur, scope: :projet_id

  before_create :generate_token

  private
  def generate_token
    sha = Digest::SHA2.new << Time.now.to_i.to_s + Time.now.usec.to_s
    self.token = sha.to_s
  end
end
