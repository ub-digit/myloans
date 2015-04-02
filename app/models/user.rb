class User
  attr_accessor :checkouts, :requests, :fines, :total_fine, :patron_type
  attr_accessor :name, :expiration_date, :communication_preference, :preferred_language, :barcode
  attr_accessor :street, :postal_code, :city, :phone_nr, :mobile_nr, :email

  include ActiveModel::Validations
  include InactiveRecord
  validates :preferred_language, :inclusion => {:in => [nil, 'swe', 'eng']}
  validates :city, :presence => true
  validates :postal_code, :presence => true
  validates :street, :presence => true
  validates :communication_preference, :inclusion => {:in => [nil, 0,1,2,3]}
  validate :email_valid

  def email_valid
    # If email exists, check that format is correct
    if self.email.present?
      unless self.email =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
        errors.add(:email,'WRONG_FORMAT');
      end
    end

    # If communication preference contains email, it has to exist
    if [1,3].include?(self.communication_preference.to_i)
      if !self.email.present?
        errors.add(:email, "EMPTY")
      end
    end
  end

  # Return params for GundaApi class unless model is invalid
  def gunda_params
    #pp self.valid?
    #pp errors.messages
    return nil unless self.valid?

    hash = {
      barcode: barcode,
      primaryAddress: {
        street: street,
        postalCode: postal_code,
        city: city,
        telephone: phone_nr,
        telephoneSpecial: mobile_nr,
        email: email
        },
      communicationPreference: communication_preference,
      language: preferred_language
    }

    return hash
  end
end
