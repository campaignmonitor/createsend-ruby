require 'createsend'
require 'pp'

cs = CreateSend.new

# Get a client
clients = cs.clients
client_id = clients.first.ClientID
puts "\nOur client: #{clients.first.Name}"
client = Client.new(client_id)

# Show full details
puts "\nClient's full details:"
cl = client.details
pp cl.BasicDetails
pp cl.AccessAndBilling

# Get their lists
puts "\nTheir lists:"
client.lists.each do |l|
  puts l.Name
end

# Get their segments
puts "\nTheir segments:"
client.segments.each do |s|
  puts "List: #{s.ListID}; Segment name: #{s.Name}"
end

# And their sent campaigns, just for fun
puts "\nTheir sent campaigns:"
client.campaigns.each do |c|
  puts c.Subject
end

# And draft campaigns
puts "\nTheir drafts:"
client.drafts.each do |d|
  puts d.Subject
end

puts "\nTheir suppression list:"
client.suppressionlist.each do |s|
  puts s.EmailAddress
end

puts "\nTheir templates:"
client.templates.each do |t|
  puts t.Name
end

# Get your api key using your username and password
#apikey = cs.apikey "iamadesigner.createsend.com", "myusername", "mypassword"
#puts "\nYour API key: #{apikey.ApiKey}"

# Create a new client
#new_client_id = Client.create 'Widget Lovers', 'Widget Lovers', 'hello@example.com', '(GMT+10:00) Canberra, Melbourne, Sydney', 'Australia'
#pp new_client

puts "\n"
