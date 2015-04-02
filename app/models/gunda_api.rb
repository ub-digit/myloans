require 'savon'

class GundaApi

  # Returns a User object incl. dependencies
  def self.find_user(pnr)
    #client = Savon.client(wsdl: "#{APP_CONFIG['api_url']}/patronAccount.wsdl", basic_auth: [APP_CONFIG['api_user'], APP_CONFIG["api_password"]])
    client = getSoapClient('patronAccount.wsdl')

    response = client.call(:patron_account, message: { barcode: pnr })

    user = User.new

    response = response.body[:patron_account_response]
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

    user.total_fine = response[:fines][:@total_balance].to_i

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
        checkout.checkout_id = checkout_raw[:@checkout_id]
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
        request.id = req_raw[:@request_id]
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

    #client = Savon.client(wsdl: "#{APP_CONFIG['api_url']}/authenticatePatron.wsdl", basic_auth: [APP_CONFIG['api_user'], APP_CONFIG["api_password"]])
    client = getSoapClient('authenticatePatron.wsdl')
    response = client.call(:authenticate_patron, message: {barcode: username, password: password})

    authenticated = response.body[:authenticate_patron_response][:authenticated]

    return authenticated
  end

  # Cancels a request based on barcode and request_id
  def self.cancel_request(request_id:, barcode:)
    client = getSoapClient('request.wsdl')

    response = client.call(:cancel, message: {patronBarcode: barcode, id: request_id})
    cancelled = response.body[:cancel_response][:success].to_i == 1

    return cancelled
  end

  # Renews a checkout based on barcode and checkout_id
  def self.renew(barcode:, checkout_id:)
    client = getSoapClient('renewal.wsdl')
    response = client.call(:renewal, message: {patronBarcode: barcode, selectedCheckouts: {:@checkoutId => checkout_id}})

    if response.body[:renewal_response][:successful_renewals][:@count] == "1"
      checkout_data = response.body[:renewal_response][:successful_renewals][:renewal]
      
      checkout = Checkout.new
      checkout.barcode = checkout_data[:item][:@barcode]
      checkout.title = checkout_data[:item][:@title]
      checkout.checkout_id = checkout_id
      checkout.due_date = checkout_data[:@due_date]
      checkout.recallable_date = checkout_data[:@recallable_date]
      checkout.status = "checkedOut"
      checkout.renewable = false

      return checkout
    else 
      return nil
    end
  end

  def self.update_user(params)
    client = getSoapClient('patronUpdate.wsdl')
    response = client.call(:patron_update, message: params)

    updated = response.body[:patron_update_response][:success]

    return updated
  end

  def self.getSoapClient(endpoint)
    Savon.client(wsdl: "#{APP_CONFIG['api_url']}/#{endpoint}", basic_auth: [APP_CONFIG['api_user'], APP_CONFIG["api_password"]])
  end

end
