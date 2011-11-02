class Customer < SourceAdapter
  def initialize(source)
    @base = 'http://rhostore.heroku.com/customers'
    super(source)
  end

  def login
    # TODO: Login to your data source here if necessary
  end

  def query(params=nil)

    puts "### Inside query..."
    parsed=JSON.parse(RestClient.get("#{@base}.json").body)

    @result={}
    parsed.each { |item|@result[item["customer"]["id"].to_s]=item["customer"] } if parsed
    puts "### Inside query, @result: #{@result.inspect}"
    @result

  end

  def sync
    # Manipulate @result before it is saved, or save it 
    # yourself using the Rhoconnect::Store interface.
    # By default, super is called below which simply saves @result
    super
  end

  def create(create_hash)
    res = RestClient.post(@base,:customer => name_value_list)

    # after create we are redirected to the new record.
    # We need to get the id of that record and return it as part of create
    # so rhosync can establish a link from its temporary object on the
    # client to this newly created object on the server
    JSON.parse(RestClient.get("#{res.headers[:location]}.json").body)["customer"]["id"]

  end

  def update(update_hash)
    obj_id = name_value_list['id']
    name_value_list.delete('id')
    RestClient.put("#{@base}/#{obj_id}",:customer => name_value_list)
  end

  def delete(delete_hash)
    RestClient.delete("#{@base}/#{name_value_list['id']}")
  end

  def logoff
    # TODO: Logout from the data source if necessary
  end
end
