require File.dirname(__FILE__) + '/helper'

class AdministratorTest < Test::Unit::TestCase
  context "when an api caller is authenticated" do
    setup do
      @api_key = '123123123123123123123'
      CreateSend.api_key @api_key
      @admin = CreateSend::Administrator.new "admin@example.com"
    end
    
    should "get a administrator by email address" do
      email = "admin@example.com"
      stub_get(@api_key, "admins.json?email=#{CGI.escape(email)}", "admin_details.json")      
      admin = CreateSend::Administrator.get email
      admin.EmailAddress.should == email
      admin.Name.should == "Admin One"
      admin.Status.should == "Active"
    end

    should "add an administrator" do
      stub_post(@api_key, "admins.json", "add_admin.json")
      result = CreateSend::Administrator.add "admin@example.com", "Admin"
      result.EmailAddress.should == "admin@example.com"
    end

    should "update an administrator" do
      email = "admin@example.com"
      new_email = "new_email_address@example.com"
      stub_put(@api_key, "admins.json?email=#{CGI.escape(email)}", nil)
      @admin.update new_email, "Admin Name"
      @admin.email_address.should == new_email
    end
      
    should "delete an admin" do
      stub_delete(@api_key, "admins.json?email=#{CGI.escape(@admin.email_address)}", nil)
      @admin.delete
    end
  end
end