# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe ShopsOpportunity do
  before(:each) do
    @valid_attributes = {
      shop: mock_model(Shop),
      opportunity: mock_model(Opportunity)
    }
  end

  it "should create a new instance given valid attributes" do
    ShopsOpportunity.create!(@valid_attributes)
  end
end
