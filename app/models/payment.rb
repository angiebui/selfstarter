class Payment < ActiveRecord::Base
  attr_accessible :ct_payment_id, :status, :amount, :user_fee_amount, :admin_fee_amount, :fullname, :email,
				  :card_type, :card_last_four, :card_expiration_month, :card_expiration_year,
				  :address_one, :address_two, :city, :state, :postal_code, :country, :quantity,
				  :additional_info

  validates :fullname, :quantity, presence: true
  validate :email, presence: true, email: true

  belongs_to :campaign
  belongs_to :reward

  def self.to_csv(options={})
    db_columns = %w{fullname email quantity amount user_fee_amount created_at status ct_payment_id}
    csv_columns = ['Name', 'Email', 'Quantity', 'Amount', 'User Fee', 'Date', 'Status', 'ID']

    if self.first
      db_columns.delete('quantity') and csv_columns.delete('Quantity') if self.first.campaign.goal_type == 'dollars'
    end

    CSV.generate(options) do |csv|
      csv << csv_columns
      all.each do |product|
        csv << product.attributes.values_at(*db_columns)
      end
    end
  end

  def update_api_data(payment)
    self.ct_payment_id = payment['id']
    self.status = payment['status']
    self.amount = payment['amount']
    self.user_fee_amount = payment['user_fee_amount']
    self.admin_fee_amount = payment['admin_fee_amount']
    self.card_type = payment['card']['card_type']
    self.card_last_four = payment['card']['last_four']
    self.card_expiration_month = payment['card']['expiration_month']
    self.card_expiration_year = payment['card']['expiration_year']
  end

end
