class Agent < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :cas_authenticatable, :trackable

  def cas_extra_attributes=(extra_attributes)
    puts extra_attributes
  end
end
