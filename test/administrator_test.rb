require File.dirname(__FILE__) + '/helper'

class AdministratorTest < Test::Unit::TestCase
  multiple_contexts "authenticated_using_oauth_context", "authenticated_using_api_key_context" do
    setup do
      @admin = CreateSend::Administrator.new @auth, "admin@example.com"
    end

    should "get a administrator by email address" do
      email = "admin@example.com"
      stub_get(@auth, "admins.json?email=#{CGI.escape(email)}", "admin_details.json")
      admin = CreateSend::Administrator.get @auth, email
      admin.EmailAddress.should == email
      admin.Name.should == "Admin One"
      admin.Status.should == "Active"
    end

    should "add an administrator" do
      stub_post(@auth, "admins.json", "add_admin.json")
      result = CreateSend::Administrator.add @auth, "admin@example.com", "Admin"
      result.EmailAddress.should == "admin@example.com"
    end

    should "update an administrator" do
      email = "admin@example.com"
      new_email = "new_email_address@example.com"
      stub_put(@auth, "admins.json?email=#{CGI.escape(email)}", nil)
      @admin.update new_email, "Admin Name"
      @admin.email_address.should == new_email
    end

    should "delete an admin" do
      stub_delete(@auth, "admins.json?email=#{CGI.escape(@admin.email_address)}", nil)
      @admin.delete
    end
  end
end