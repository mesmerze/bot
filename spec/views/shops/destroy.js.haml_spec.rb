# frozen_string_literal: true

require 'spec_helper'

describe '/shops/destroy' do
  before do
    login
    assign(:shop, @shop = FactoryGirl.build_stubbed(:shop))
    assign(:shops, [@shop].paginate)
    render
  end

  it 'should blind up destroyed shop partial' do
    expect(rendered).to include('slideUp')
  end

  it 'should update shops pagination' do
    expect(rendered).to include('#paginate')
  end
end
