# frozen_string_literal: true

require 'spec_helper'

describe '/shops/create' do
  before do
    login
  end

  context 'create success' do
    before do
      assign(:shop, @shop = FactoryGirl.build_stubbed(:shop))
      assign(:shops, [@shop].paginate)
      render
    end

    it 'should hide create shop and insert shop partial' do
      expect(rendered).to include("$('#shops').prepend('<li class=\\'highlight shop\\' id=\\'shop_#{@shop.id}\\'")
      expect(rendered).to include(%/$('#shop_#{@shop.id}').effect("highlight"/)
    end

    it 'should update pagination' do
      expect(rendered).to include('#paginate')
    end

    it 'should refresh shops sidebar' do
      expect(rendered).to include('#sidebar')
      expect(rendered).to have_text('Recent Items')
    end
  end

  context 'create failure' do
    it 'should re-render create template' do
      assign(:shop, FactoryGirl.build(:shop, name: nil))
      assign(:users, [current_user])
      render

      expect(rendered).to include("#create_shop")
      expect(rendered).to include(%/$('#create_shop').effect("shake"/)
    end
  end
end
