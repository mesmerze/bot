# frozen_string_literal: true

require 'spec_helper'

describe '/shops/new' do
  before do
    login
    assign(:shop, Shop.new(user: current_user))
    assign(:users, [current_user])
  end

  it 'should toggle empty message div if it exists' do
    render

    expect(rendered).to include("crm.flick('empty', 'toggle')")
  end

  describe 'new shop' do
    it 'should render new into create_shop div' do
      params[:cancel] = nil
      render

      expect(rendered).to include('#create_shop')
      expect(rendered).to include("crm.flip_form('create_shop');")
    end
  end

  describe 'cancel new shop' do
    it 'should hide [create shop] form()' do
      params[:cancel] = 'true'
      render

      expect(rendered).not_to include('#create_shop')
      expect(rendered).to include("crm.flip_form('create_shop');")
    end
  end
end
