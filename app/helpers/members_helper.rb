module MembersHelper
  #VARIABLES 
  @@accept = "application/vnd.mx.api.v1+json"
  @@content_type = "application/json"
  @@base_url = "https://int-api.mx.com" 

  def list_institutions(page = 1, records_per_page = 1000)
    HTTP.headers(:accept => @@accept)
        .basic_auth(:user => ENV["API_USERNAME"] ,
          :pass => ENV["API_PASSWORD"])
        .get("#{@@base_url}/institutions", params: { :page => page, 
                                                     :records_per_page => records_per_page})
                                                     .parse["institutions"]
  end

end
