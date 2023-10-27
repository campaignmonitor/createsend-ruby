require File.dirname(__FILE__) + '/helper'

class SegmentTest < Test::Unit::TestCase
  multiple_contexts "authenticated_using_oauth_context", "authenticated_using_api_key_context" do
    setup do
      @segment = CreateSend::Segment.new @auth, '98y2e98y289dh89h938389'
    end

    should "create a new segment" do
      list_id = "2983492834987394879837498"
      rule_groups = [ { :Rules => [ { :RuleType => "EmailAddress", :Clause => "CONTAINS example.com" } ] } ]
      stub_post(@auth, "segments/#{list_id}.json", "create_segment.json")
      res = CreateSend::Segment.create @auth, list_id, "new segment title", rule_groups
      res.should be == "0246c2aea610a3545d9780bf6ab89006"
    end

    should "update a segment" do
      rules = [ { :Rules => [ { :RuleType => "Name", :Clause => "PROVIDED" } ] } ]
      stub_put(@auth, "segments/#{@segment.segment_id}.json", nil)
      @segment.update "new title for segment", rules
    end

    should "add a rule group to a segment" do
      rule_group = [ { :RuleType => "EmailAddress", :Clause => "CONTAINS @hello.com" } ]
      stub_post(@auth, "segments/#{@segment.segment_id}/rules.json", nil)
      @segment.add_rule_group rule_group
    end

    should "get the active subscribers for a particular segment in the list" do
      min_date = "2010-01-01"
      stub_get(@auth, "segments/#{@segment.segment_id}/active.json?pagesize=1000&orderfield=email&page=1&orderdirection=asc&date=#{ERB::Util.url_encode(min_date)}&includetrackingpreference=false",
        "segment_subscribers.json")
      res = @segment.subscribers min_date
      res.ResultsOrderedBy.should be == "email"
      res.OrderDirection.should be == "asc"
      res.PageNumber.should be == 1
      res.PageSize.should be == 1000
      res.RecordsOnThisPage.should be == 2
      res.TotalNumberOfRecords.should be == 2
      res.NumberOfPages.should be == 1
      res.Results.size.should be == 2
      res.Results.first.EmailAddress.should be == "personone@example.com"
      res.Results.first.Name.should be == "Person One"
      res.Results.first.Date.should be == "2010-10-27 13:13:00"
      res.Results.first.ListJoinedDate.should be == "2010-10-27 13:13:00"
      res.Results.first.State.should be == "Active"
      res.Results.first.CustomFields.should be == []
    end

    should "delete a segment" do
      stub_delete(@auth, "segments/#{@segment.segment_id}.json", nil)
      @segment.delete
    end

    should "get the details of a segment" do
      stub_get(@auth, "segments/#{@segment.segment_id}.json", "segment_details.json")
      res = @segment.details
      res.ActiveSubscribers.should be == 0
      res.RuleGroups.size.should be == 2
      res.RuleGroups.first.Rules.size.should be == 1
      res.RuleGroups.first.Rules.first.RuleType.should be == "EmailAddress"
      res.RuleGroups.first.Rules.first.Clause.should be == "CONTAINS @hello.com"
      res.ListID.should be == "2bea949d0bf96148c3e6a209d2e82060"
      res.SegmentID.should be == "dba84a225d5ce3d19105d7257baac46f"
      res.Title.should be == "My Segment"
    end

    should "clear a segment's rules" do
      stub_delete(@auth, "segments/#{@segment.segment_id}/rules.json", nil)
      @segment.clear_rules
    end

  end
end
