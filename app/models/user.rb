class User
  attr_accessor :checkouts, :requests, :fines, :total_fine, :patron_type
  attr_accessor :name, :expiration_date, :communication_preference, :preferred_language, :barcode
  attr_accessor :street, :postal_code, :city, :phone_nr, :mobile_nr, :email

  include ActiveModel::Validations
  include GeneralInit
  validates :preferred_language, :inclusion => {:in => [nil, 'swe', 'eng']}
  validates :city, :presence => true
  validates :postal_code, :presence => true
  validates :street, :presence => true
  validates :communication_preference, :inclusion => {:in => [nil, 1,2,3,4]}


  # Return params for GundaApi class unless model is invalid
  def gunda_params
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
