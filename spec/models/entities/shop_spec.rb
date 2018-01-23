# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Shop do
  it "should create a new instance given valid attributes" do
    Shop.create!(name: "Shop", stage: 'inactive_seasonal')
  end

  context 'attach opportunity and contact to shop' do
    before do
      @account = create(:account)
      @shop = create(:shop, account: @account, user: current_user)
      @contact = create(:contact)
      @opportunity = create(:opportunity)
    end

    it 'should return asset when attaching asset which belongs to shop.account' do
      expect(@account.attach!(@contact)).to eq([@contact])
      expect(@account.attach!(@opportunity)).to eq([@opportunity])
      expect(@shop.attach!(@contact)).to eq([@contact])
      expect(@shop.attach!(@opportunity)).to eq([@opportunity])
    end

    it 'should return nil when attaching asset which not belongs to shop.account' do
      expect(@shop.attach!(@contact)).to eq(nil)
      expect(@shop.attach!(@opportunity)).to eq(nil)
    end

    it "should return nil when attaching existing asset" do
      @shop.contacts << @contact
      @shop.opportunities << @opportunity
      expect(@shop.attach!(@contact)).to eq(nil)
      expect(@shop.attach!(@opportunity)).to eq(nil)
    end
  end

  context 'discard' do
    before do
      @shop = create(:shop, user: current_user)
      @contact = create(:contact)
      @opportunity = create(:opportunity)
      @shop.contacts << @contact
      @shop.opportunities << @opportunity
    end

    it "should discard contact and opportunity" do
      @shop.discard!(@contact)
      @shop.discard!(@opportunity)
      expect(@shop.contacts).to eq([])
      expect(@shop.opportunities).to eq([])
      expect(@shop.contacts.count).to eq(0)
      expect(@shop.opportunities.count).to eq(0)
    end
  end

  describe "permissions" do
    it_should_behave_like Ability, Shop
  end
end
