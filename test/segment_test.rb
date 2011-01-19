require File.dirname(__FILE__) + '/helper'

class SegmentTest < Test::Unit::TestCase
  context "when an api caller is authenticated" do
    setup do
      @api_key = '123123123123123123123'
      CreateSend.api_key @api_key
      @segment = CreateSend::Segment.new('98y2e98y289dh89h938389')
    end

    should "create a new segment" do
      list_id = "2983492834987394879837498"
      rules = [ { :Subject => "EmailAddress", :Clauses => [ "CONTAINS example.com" ] } ]
      stub_post(@api_key, "segments/#{list_id}.json", "create_segment.json")
      res = CreateSend::Segment.create list_id, "new segment title", rules
      res.should == "0246c2aea610a3545d9780bf6ab89006"
    end

    should "update a segment" do
      rules = [ { :Subject => "Name", :Clauses => [ "EQUALS subscriber" ] } ]
      stub_put(@api_key, "segments/#{@segment.segment_id}.json", nil)
      @segment.update "new title for segment", rules
    end
    
    should "add a rule to a segment" do
      clauses = [ "CONTAINS example.com" ]
      stub_post(@api_key, "segments/#{@segment.segment_id}/rules.json", nil)
      @segment.add_rule "EmailAddress", clauses
    end

    should "get the active subscribers for a particular segment in the list" do
      min_date = "2010-01-01"
      stub_get(@api_key, "segments/#{@segment.segment_id}/active.json?pagesize=1000&orderfield=email&page=1&orderdirection=asc&date=#{CGI.escape(min_date)}",
        "segment_subscribers.json")
      res = @segment.subscribers min_date
      res.ResultsOrderedBy.should == "email"
      res.OrderDirection.should == "asc"
      res.PageNumber.should == 1
      res.PageSize.should == 1000
      res.RecordsOnThisPage.should == 2
      res.TotalNumberOfRecords.should == 2
      res.NumberOfPages.should == 1
      res.Results.size.should == 2
      res.Results.first.EmailAddress.should == "personone@example.com"
      res.Results.first.Name.should == "Person One"
      res.Results.first.Date.should == "2010-10-27 13:13:00"
      res.Results.first.State.should == "Active"
      res.Results.first.CustomFields.should == []
    end
    
    should "delete a segment" do
      stub_delete(@api_key, "segments/#{@segment.segment_id}.json", nil)
      @segment.delete
    end

    should "get the details of a segment" do
      stub_get(@api_key, "segments/#{@segment.segment_id}.json", "segment_details.json")
      res = @segment.details
      res.ActiveSubscribers.should == 0
      res.Rules.size.should == 2
      res.Rules.first.Subject.should == "EmailAddress"
      res.Rules.first.Clauses.size.should == 1
      res.Rules.first.Clauses.first.should == "CONTAINS @hello.com"
      res.ListID.should == "2bea949d0bf96148c3e6a209d2e82060"
      res.SegmentID.should == "dba84a225d5ce3d19105d7257baac46f"
      res.Title.should == "My Segment"
    end

    should "clear a segment's rules" do
      stub_delete(@api_key, "segments/#{@segment.segment_id}/rules.json", nil)
      @segment.clear_rules
    end

  end
end
