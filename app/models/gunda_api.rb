require 'savon'

class GundaApi

  # Returns a User object incl. dependencies
  def self.find_user(pnr)
    client = Savon.client(wsdl: "#{APP_CONFIG['api_url']}/patronAccount.wsdl", basic_auth: [APP_CONFIG['api_user'], APP_CONFIG["api_password"]])

    response = client.call(:patron_account, message: { barcode: pnr })

    user = User.new

    response = response.body[:patron_account_response]

    contact_information = response[:contact_information]
    user.street = contact_information[:primary_address][:street]
    user.city = contact_information[:primary_address][:city]
    user.postal_code = contact_information[:primary_address][:postal_code]
    user.phone_nr = contact_information[:primary_address][:telephone]
    user.mobile_nr = contact_information[:primary_address][:telephone_special]

    # Create loan objects
    loans = []
    #puts response[:checkouts][:checkout]
    response[:checkouts][:checkout].each do |checkout|
      loan = Loan.new
      pp checkout
      loan.barcode = checkout[:checkout_item][:@barcode]
      loan.title = checkout[:checkout_bibliographic_record][:@title]
      loan.due_date = checkout[:@due_date]
      loan.recallable_date = checkout[:@recallable_date]
      loan.status = checkout[:@status]
      loan.renewable = checkout[:@renewable]

      loans << loan

    
    end

    user.current_loans = loans
    return user
  end

end