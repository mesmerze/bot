# frozen_string_literal: true

require 'spec_helper'

describe '/shops/update' do
  before do
    login

    assign(:shop, @shop = build_stubbed(:shop, user: current_user))
    assign(:users, [current_user])
  end

  context 'without errors on index' do
    before do
      controller.request.env['HTTP_REFERER'] = 'http://localhost/shops'
    end

    it 'should replace edit_shop with shop partial and highlight it' do
      render

      expect(rendered).to include("#shop_#{@shop.id}")
      expect(rendered).to include(%/$('#shop_#{@shop.id}').effect("highlight"/)
    end
  end

  context 'without errors on landing page' do
    before do
      controller.request.env['HTTP_REFERER'] = 'http://localhost/shops/13'
    end

    it 'should flip edit_shop' do
      render
      expect(rendered).not_to include("shop_#{@shop.id}")
      expect(rendered).to include("crm.flip_form('edit_shop'")
    end
  end

  context 'validation fail' do
    before do
      @shop.errors.add(:name)
    end

    describe 'on landing page' do
      before do
        controller.request.env['HTTP_REFERER'] = 'http://localhost/shops/13'
      end

      it 'should redraw the edit_shop' do
        render

        expect(rendered).to include('#edit_shop')
        expect(rendered).to include('focus()')
      end
    end

    describe 'on index page' do
      before do
        controller.request.env['HTTP_REFERER'] = 'http://localhost/shops'
      end

      it 'should redraw the edit_shop' do
        render

        expect(rendered).to include("shop_#{@shop.id}")
        expect(rendered).to include('focus()')
      end
    end
  end
end
