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
pp cl

# Get their lists
puts "\nTheir lists:"
client.lists.each do |l|
  puts l.Name
end

# Get a subscriber
puts "\nGetting a subscriber..."
subs = Subscriber.get "2fe4c8f0373ce320e2200596d7ef168f", "jamesd+7t8787Y@freshview.com"
pp subs

puts "\nGetting a subscriber's history..."
s = Subscriber.new "adb870d33204f211926ff7870c6a3268", "jamesd+8798u98u@freshview.com"
history = s.history
pp history

# Unsubscribe a subscriber
# puts "\nUnsubscribing a subscriber..."
# s = Subscriber.new "2fe4c8f0373ce320e2200596d7ef168f", "subscriber@example.com"
# s.unsubscribe

# Add a subscriber
# puts "\nAdding a subscriber..."
# custom_fields = [
#   {
#     :Key => "website",
#     :Value => "http://subdomain.example.com"
#   }
# ]
# email = Subscriber.add "2fe4c8f0373ce320e2200596d7ef168f", "jamesd+7890909i0ggg@freshview.com", "Jimmy", custom_fields, true
# pp email

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

# Create a new template for the client
# template_id = Template.create(client.client_id, "My new template", "http://www.mailshot.co.nz/my-account/templates/single.html", 
#   "http://www.mailshot.co.nz/my-account/templates/single.zip", "http://www.mailshot.co.nz/my-account/templates/single.jpg")
# template = Template.new(template_id)
# puts "\nCreated template with ID: #{template.template_id}"

# Show template details
# puts "\nThe template in all its glory:"
# deets = template.details
# puts deets.Name
# puts deets.TemplateID
# puts deets.PreviewURL
# puts deets.ScreenshotURL

# Update the template
# puts "\nUpdating the template..."
# template.update("My updated template", "http://www.mailshot.co.nz/my-account/templates/single.html", 
#   "http://www.mailshot.co.nz/my-account/templates/single.zip", "http://www.mailshot.co.nz/my-account/templates/single.jpg")

# Show template details, again
# puts "\nThe template in all its glory:"
# deets = template.details
# puts deets.Name
# puts deets.TemplateID
# puts deets.PreviewURL
# puts deets.ScreenshotURL

# Delete the template
#puts "\nDeleting the template now..."
#template.delete

# puts "\nUpdate their basic details..."
# client.set_basics "The Basics", "The Basics", "jamesd+iuh987h98wh9@freshview.com", "(GMT+10:00) Canberra, Melbourne, Sydney", "Australia"
# cl = client.details
# pp cl
# 
# puts "\nUpdate their access details..."
# client.set_access "basics", "basics", 63
# cl = client.details
# pp cl

puts "\n"
