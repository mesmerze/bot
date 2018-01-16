# frozen_string_literal: true

require 'spec_helper'

describe '/shops/edit' do
  before do
    login
    assign(:shop, @shop = FactoryGirl.build_stubbed(:shop, user: current_user))
    assign(:users, [current_user])
  end

  it 'cancel from shops index page: should replace edit shop with shop partial' do
    params[:cancel] = 'true'

    render
    expect(rendered).to include("shop_#{@shop.id}")
  end

  it 'cancel from shop landing page: should hide edit shop form' do
    controller.request.env['HTTP_REFERER'] = 'http://localhost/shops/123'
    params[:cancel] = 'true'

    render
    expect(rendered).to include("crm.flip_form('edit_shop'")
  end

  it 'should hide previously open edit shop for and replace it with shop partial' do
    params[:cancel] = nil
    assign(:previous, previous = FactoryGirl.build_stubbed(:shop, user: current_user))

    render
    expect(rendered).to include("shop_#{previous.id}")
  end

  it 'should remove previously open edit shop if it\'s no longer available' do
    params[:cancel] = nil
    assign(:previous, previous = 13)

    render
    expect(rendered).to include("crm.flick('shop_#{previous}', 'remove');")
  end

  it 'should turn off highlight and hide create shop and replace current shop with edit' do
    params[:cancel] = nil

    render
    expect(rendered).to include("crm.highlight_off('shop_#{@shop.id}');")
    expect(rendered).to include("crm.hide_form('create_shop')")
    expect(rendered).to include("shop_#{@shop.id}")
  end

  it 'from shop landing page should show edit shop' do
    params[:cancel] = 'false'

    render
    expect(rendered).to include('edit_shop')
    expect(rendered).to include("crm.flip_form('edit_shop'")
  end
end
