# frozen_string_literal: true

require 'spec_helper'

describe DashboardController do
  describe "responding to GET sales dashboard" do
    before(:each) do
      login
      @user = @current_user
      @group = Group.create(name: 'test')
      @user.update_attributes(first_name: "Apple", last_name: "Boy", groups: [@group])
    end

    it "should assign @users_with_opportunities" do
      create(:opportunity, stage: "prospecting", assignee: @user)
      get :index, xhr: true
      expect(assigns[:users_with_opportunities]).to eq(@group.id => [@current_user])
    end

    it "@users_with_opportunities should be ordered by name" do
      create(:opportunity, stage: "prospecting", assignee: @user)

      user1 = create(:user, first_name: "Zebra", last_name: "Stripes", groups: [@group])
      create(:opportunity, stage: "prospecting", assignee: user1)

      user2 = create(:user, first_name: "Bilbo", last_name: "Magic", groups: [@group])
      create(:opportunity, stage: "prospecting", assignee: user2)

      get :index, xhr: true

      expect(assigns[:users_with_opportunities]).to eq(@group.id => [@user, user2, user1])
    end

    it "should assign @unassigned_opportunities with only open unassigned opportunities" do
      @o1 = build(:opportunity, stage: "prospecting", assignee: nil)
      @o2 = build(:opportunity, stage: "won", assignee: nil)
      @o3 = build(:opportunity, stage: "prospecting", assignee: nil)
      [@o1, @o2, @o3].each { |o| o.save(validate: false) }

      get :index, xhr: true

      expect(assigns[:unassigned_opportunities]).to include(@o1, @o3)
      expect(assigns[:unassigned_opportunities]).not_to include(@o2)
    end

    it "@unassigned_opportunities should be ordered by stage" do
      @o1 = build(:opportunity, stage: "proposal", assignee: nil)
      @o2 = build(:opportunity, stage: "prospecting", assignee: nil)
      @o3 = build(:opportunity, stage: "negotiation", assignee: nil)
      [@o1, @o2, @o3].each { |o| o.save(validate: false) }

      get :index, xhr: true

      expect(assigns[:unassigned_opportunities]).to eq([@o3, @o1, @o2])
    end

    it "should not include users who have no assigned opportunities" do
      get :index, xhr: true
      expect(assigns[:users_with_opportunities]).to eq({})
    end

    it "should not include users who have no open assigned opportunities" do
      create(:opportunity, stage: "won", assignee: @user)

      get :index, xhr: true
      expect(assigns[:users_with_opportunities]).to eq({})
    end

    it "should render sales dashboard" do
      get :index
      expect(response).to render_template("dashboard/index")
    end

    it "should render sales dashboard" do
      get :index, xhr: true
      expect(response).to render_template("dashboard/redraw")
    end
  end
end
