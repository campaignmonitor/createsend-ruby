require File.dirname(__FILE__) + '/helper'

class TemplateTest < Test::Unit::TestCase
  context "when an api caller is authenticated" do
    setup do
      @api_key = '123123123123123123123'
      CreateSend.api_key @api_key
      @template = CreateSend::Template.new('98y2e98y289dh89h938389')
    end

    should "create a template" do
      client_id = '87y8d7qyw8d7yq8w7ydwqwd'
      stub_post(@api_key, "templates/#{client_id}.json", "create_template.json")
      template_id = CreateSend::Template.create client_id, "Template One", "http://templates.org/index.html", 
        "http://templates.org/files.zip"
      template_id.should == "98y2e98y289dh89h938389"
    end

    should "get details of a template" do
      stub_get(@api_key, "templates/#{@template.template_id}.json", "template_details.json")
      t = @template.details
      t.TemplateID.should == "98y2e98y289dh89h938389"
      t.Name.should == "Template One"
      t.PreviewURL.should == "http://preview.createsend.com/createsend/templates/previewTemplate.aspx?ID=01AF532CD8889B33&d=r&c=E816F55BFAD1A753"
      t.ScreenshotURL.should == "http://preview.createsend.com/ts/r/14/833/263/14833263.jpg?0318092600"
    end

    should "update a template" do
      stub_put(@api_key, "templates/#{@template.template_id}.json", nil)
      @template.update "Template One Updated", "http://templates.org/index.html", "http://templates.org/files.zip"
    end

    should "delete a template" do
      stub_delete(@api_key, "templates/#{@template.template_id}.json", nil)
      @template.delete
    end
  end
end
