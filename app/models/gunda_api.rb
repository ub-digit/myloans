require 'savon'

class GundaApi

  def self.find_user(pnr)
    client = Savon.client(wsdl: 'http://testlunda.ub.gu.se:8080/chamo/svc/patronAccount.wsdl', basic_auth: [APP_CONFIG['api_user'], APP_CONFIG["api_password"]])

    pp client.operations
    response = client.call(:patron_account, message: { barcode: pnr })
    pp response
    pp response.body
  end

end