# frozen_string_literal: true

require 'spec_helper'

describe '/shops/show' do
  before do
    login
    @shop = create(:shop, id: 13,
                          contacts: [create(:contact)],
                          opportunities: [create(:opportunity)])
    assign(:shop, @shop)
    assign(:users, [current_user])
  end

  it 'should render shop landing page' do
    render

    expect(view).to render_template(partial: 'contacts/_contact')
    expect(view).to render_template(partial: 'opportunities/_opportunity')

    expect(rendered).to have_tag('div[id=edit_shop]')
  end
end
