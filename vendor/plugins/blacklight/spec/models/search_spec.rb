require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Search do
  describe "query_params" do
    before(:each) do
      @search = Search.new
      @query_params = { :q => "query", :f => "facet" }
    end
    it "should accept a Hash as the value and save without error" do
      @search.query_params = @query_params
      assert @search.save
    end
    it "should return a Hash as the value" do
      @search.query_params = @query_params
      assert @search.save
      Search.find(@search.id).query_params.should == @query_params
    end
  end
  
  describe "saved?" do
    it "should be true when user_id is not NULL and greater than 0" do
      @search = Search.create(:user_id => 1)
      @search.saved?.should be_true
    end
    it "should be false when user_id is NULL or less than 1" do
      @search = Search.create
      @search.saved?.should_not be_true
    end
  end
end
