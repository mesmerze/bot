# frozen_string_literal: true

require 'spec_helper'

describe '/shops/index' do
  before do
    login
  end

  it 'should render shops with @shops collection if there are shops' do
    assign(:shops, [FactoryGirl.build_stubbed(:shop, id: 13)].paginate(page: 1, per_page: 20))

    render template: 'shops/index', formats: [:js]

    expect(rendered).to include("$('#shops').html('<li class=\\'highlight shop\\' id=\\'shop_13\\'")
    expect(rendered).to include('#paginate')
  end

  it 'should render empty if @shops collection if there are no shops' do
    assign(:shops, [].paginate(page: 1, per_page: 20))

    render template: 'shops/index', formats: [:js]

    expect(rendered).to include("$('#shops').html('<div id=\\'empty\\'>")
    expect(rendered).to include('#paginate')
  end
end
