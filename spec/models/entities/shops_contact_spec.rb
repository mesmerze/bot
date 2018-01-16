# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe ShopsContact do
  before(:each) do
    @valid_attributes = {
      shop: mock_model(Shop),
      contact: mock_model(Contact)
    }
  end

  it "should create a new instance given valid attributes" do
    ShopsContact.create!(@valid_attributes)
  end
end
