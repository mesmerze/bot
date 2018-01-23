# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe '/shops/index' do
  before do
    view.lookup_context.prefixes << 'entities'
    assign :per_page, Shop.per_page
    assign :sort_by,  Shop.sort_by
    assign :ransack_search, Shop.ransack
    login
  end

  it 'should render shop name' do
    assign(:shops, [build_stubbed(:shop, name: 'New test shop'), build_stubbed(:shop)].paginate)
    render
    expect(rendered).to have_tag('a', text: 'New test shop')
  end

  it 'should render list of shops if list of shops is not empty' do
    assign(:shops, [build_stubbed(:shop), build_stubbed(:shop)].paginate)

    render
    expect(view).to render_template(partial: '_shop')
    expect(view).to render_template(partial: 'shared/_paginate_with_per_page')
  end

  it 'should render a message if there\'re no shops' do
    assign(:shops, [].paginate)

    render
    expect(view).not_to render_template(partial: '_shop')
    expect(view).to render_template(partial: 'shared/_empty')
    expect(view).to render_template(partial: 'shared/_paginate_with_per_page')
  end
end
