require File.dirname(__FILE__) + '/helper'

class SegmentTest < Test::Unit::TestCase
  context "when an api caller is authenticated" do
    setup do
      @api_key = '123123123123123123123'
      CreateSend.api_key @api_key
      @segment = Segment.new(:segment_id => '98y2e98y289dh89h938389')
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

  end
end
