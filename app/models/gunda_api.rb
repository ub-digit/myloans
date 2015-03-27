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

    contact_information           = response[:contact_information]
    user.street                   = contact_information[:primary_address][:street]
    user.city                     = contact_information[:primary_address][:city]
    user.postal_code              = contact_information[:primary_address][:postal_code]
    user.phone_nr                 = contact_information[:primary_address][:telephone]
    user.mobile_nr                = contact_information[:primary_address][:telephone_special]
    user.email                    = contact_information[:primary_address][:email]

    user.communication_preference = contact_information[:@communication_preference]
    user.preferred_language       = contact_information[:@preferred_language]

    user.total_fine = response[:fines][:@total_balance]

    user.patron_type = response[:patron_type][:@patron_type_id]
    

    # Create loan objects
    checkouts = []
    if response[:checkouts]
      if response[:checkouts][:checkout].class != Array
        array = []
        array << response[:checkouts][:checkout]
      else
        array = response[:checkouts][:checkout]
      end
      array.each do |checkout_raw|
        checkout = Checkout.new

        checkout.barcode = checkout_raw[:checkout_item][:@barcode]
        checkout.title = checkout_raw[:checkout_bibliographic_record][:@title]
        checkout.due_date = checkout_raw[:@due_date]
        checkout.recallable_date = checkout_raw[:@recallable_date]
        checkout.status = checkout_raw[:@status]
        checkout.renewable = checkout_raw[:@renewable]

        checkouts << checkout
      end
    end
    user.checkouts = checkouts

    # Create request objects
    requests = []
    if response[:requests]

      # Create encapsulating array if only one record is present
      if response[:requests][:request].class != Array
        array = []
        array << response[:requests][:request]
      else
        array = response[:requests][:request]
      end

      array.each do |req_raw|
        request = Request.new
        #puts req
        request.title = req_raw[:request_bibliographic_record][:@title]
        request.pickup_location = req_raw[:pickup_location][:@pickup_location_name]
        request.expiration_date = req_raw[:@expiration_date]
        request.status = req_raw[:@status]
        request.queue_position = req_raw[:@queue_position]

        requests << request
      end
    end
    user.requests = requests

    fines = []
    if response[:fines][:fine]

      if response[:fines][:fine].class != Array
        array = []
        array << response[:fines][:fine]
      else
        array = response[:fines][:fine]
      end

      array.each do |fine_raw|
        fine = Fine.new
        fine.title = fine_raw[:fine_bibliographic_record][:@title]
        fine.type = fine_raw[:@fine_code].downcase.tr(" ", "_") #Turn status to snakecase
        fine.amount = fine_raw[:@amount]
        fine.balance = fine_raw[:@balance]
        fine.date = fine_raw[:@date]

        fines << fine
      end

    end
    user.fines = fines

    return user
  end

  # Authenticates a user account by username and password
  def self.authenticate_user(username:, password:)

    client = Savon.client(wsdl: "#{APP_CONFIG['api_url']}/authenticatePatron.wsdl", basic_auth: [APP_CONFIG['api_user'], APP_CONFIG["api_password"]])
    response = client.call(:authenticate_patron, message: {barcode: username, password: password})

    authenticated = response.body[:authenticate_patron_response][:authenticated]

    return authenticated
  end

end
