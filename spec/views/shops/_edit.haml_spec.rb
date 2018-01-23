# frozen_string_literal: true

require 'spec_helper'

describe '/shops/_edit' do
  before do
    login
    assign(:shop, @shop = create(:shop))
  end

  it 'should render edit form' do
    render

    expect(view).to render_template(partial: "_top_section")
    expect(view).to render_template(partial: "_permissions")

    expect(rendered).to have_tag("form[class=edit_shop]") do |form|
      expect(form).to have_tag "input[type=hidden][id=shop_user_id]"
    end
  end
end
