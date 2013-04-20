class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :fullname, :ct_user_id
                  :has_default_bank
  
  validates :fullname, presence: true
  
  has_many :orders
  
  before_save :sync_crowdtilt_user
  
  private
  
    def sync_crowdtilt_user
      if !self.ct_user_id
        begin
          user = {
            firstname: self.fullname,
            email: self.email
          }
          response = Crowdtilt.post('/users', {user: user})
        rescue => exception     
          errors.add(:base, exception.to_s)
          false
        else
          self.ct_user_id = response['user']['id']
        end          
      else
        begin
          user = {
            firstname: self.fullname,
            email: self.email
          }
          response = Crowdtilt.put('/users/' + self.ct_user_id, {user: user})
        rescue => exception     
          errors.add(:base, exception.to_s)
          false
        else
          true
       end 
      end
    end
end
