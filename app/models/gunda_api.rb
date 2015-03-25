require 'savon'

class GundaApi

  # Returns a User object incl. dependencies
  def self.find_user(pnr)
    client = Savon.client(wsdl: "#{APP_CONFIG['api_url']}/patronAccount.wsdl", basic_auth: [APP_CONFIG['api_user'], APP_CONFIG["api_password"]])

    response = client.call(:patron_account, message: { barcode: pnr })

    user = User.new

    response = response.body[:patron_account_response]
    #pp response

    user.name = response[:patron_name][:last]
    user.expiration_date = response[:expiration_date]
    user.barcode = response[:barcode].first

    contact_information = response[:contact_information]
    user.street = contact_information[:primary_address][:street]
    user.city = contact_information[:primary_address][:city]
    user.postal_code = contact_information[:primary_address][:postal_code]
    user.phone_nr = contact_information[:primary_address][:telephone]
    user.mobile_nr = contact_information[:primary_address][:telephone_special]
    user.communication_preference = contact_information[:@communication_preference]
    user.preferred_language = contact_information[:@preferred_language]

    user.total_fine = response[:fines][:@total_balance]
    

    # Create loan objects
    loans = []
    if response[:checkouts]
      response[:checkouts][:checkout].each do |checkout|
        loan = Loan.new

        loan.barcode = checkout[:checkout_item][:@barcode]
        loan.title = checkout[:checkout_bibliographic_record][:@title]
        loan.due_date = checkout[:@due_date]
        loan.recallable_date = checkout[:@recallable_date]
        loan.status = checkout[:@status]
        loan.renewable = checkout[:@renewable]

        loans << loan
      end
    end
    user.current_loans = loans

    # Create request objects
    requests = []
    if response[:requests]

      # Special handling if only one record exists
      if response[:requests][:request].first.first == :request_bibliographic_record   
        puts response[:requests][:request]
        req = response[:requests][:request]
        request = Request.new
            #puts req
            request.title = req[:request_bibliographic_record][:@title]
            request.pickup_location = req[:pickup_location][:@pickup_location_name]
            request.expiration_date = req[:@expiration_date]
            request.status = req[:@status]
            request.queue_position = req[:@queue_position]

            requests << request
      
      else

        if response[:requests][:request]
          response[:requests][:request].each do |req|
            request = Request.new
            #puts req
            request.title = req[:request_bibliographic_record][:@title]
            request.pickup_location = req[:pickup_location][:@pickup_location_name]
            request.expiration_date = req[:@expiration_date]
            request.status = req[:@status]
            request.queue_position = req[:@queue_position]

            requests << request
          end
        end
      end
    end
    user.requests = requests

    return user
  end

end