# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe '/shops/_new' do
  before do
    login
    assign(:shop, Shop.new)
    assign(:users, [current_user])
  end

  it 'should render create shop form' do
    render

    expect(view).to render_template(partial: '_top_section')

    expect(rendered).to have_tag('form[class=new_shop]')
  end
end
