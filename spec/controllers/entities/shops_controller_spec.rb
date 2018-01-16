# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe ShopsController do
  before do
    login
    set_current_tab(:shops)
  end

  context 'responding to GET index' do
    it 'should expose all shops as @shops and render index' do
      @shops = [FactoryGirl.create(:shop, user: current_user)]
      get :index
      expect(assigns[:shops]).to eq(@shops)
      expect(response).to render_template('shops/index')
    end

    it 'should perform lookup using query string' do
      @shop1 = FactoryGirl.create(:shop, user: current_user, name: 'Sirst')
      @shop2 = FactoryGirl.create(:shop, user: current_user, name: 'Second')

      get :index, params: { query: 'Second' }
      expect(assigns[:shops]).to eq([@shop2])
      expect(assigns[:current_query]).to eq('Second')
      expect(session[:shops_current_query]).to eq('Second')
    end

    describe 'AJAX pagination' do
      it 'should pick up page number from params' do
        @shops = [FactoryGirl.create(:shop, user: current_user)]
        get :index, params: { page: 42 }, xhr: true

        expect(assigns[:current_page].to_i).to eq(42)
        expect(assigns[:shops]).to eq([])
        expect(session[:shops_current_page].to_i).to eq(42)
        expect(response).to render_template('shops/index')
      end

      it 'should pick up saved page number from session' do
        session[:shops_current_page] = 42
        @shops = [FactoryGirl.create(:shop, user: current_user)]
        get :index, xhr: true

        expect(assigns[:current_page]).to eq(42)
        expect(assigns[:shops]).to eq([])
        expect(response).to render_template('shops/index')
      end

      it 'should reset current_page when query is altered' do
        session[:shops_current_page] = 42
        session[:shops_current_query] = 'shop'
        @shops = [FactoryGirl.create(:shop, user: current_user)]
        get :index, xhr: true

        expect(assigns[:current_page]).to eq(1)
        expect(assigns[:shops]).to eq(@shops)
        expect(response).to render_template('shops/index')
      end
    end

    describe 'with mime type of JSON' do
      it 'should render all shops as json' do
        expect(@controller).to receive(:get_shops).and_return(shops = double('Array of Shops'))
        expect(shops).to receive(:to_json).and_return('generated JSON')

        request.env['HTTP_ACCEPT'] = 'application/json'
        get :index
        expect(response.body).to eq('generated JSON')
      end
    end

    describe 'with mime type of XML' do
      it 'should render all shops as xml' do
        expect(@controller).to receive(:get_shops).and_return(shops = double('Array of Shops'))
        expect(shops).to receive(:to_xml).and_return('generated XML')

        request.env['HTTP_ACCEPT'] = 'application/xml'
        get :index
        expect(response.body).to eq('generated XML')
      end
    end
  end

  context 'responding to GET show' do
    describe 'with mime type of HTML' do
      before { @shop = FactoryGirl.create(:shop, user: current_user) }

      it 'should expose the requested shop as @shop and render show' do
        get :show, params: { id: @shop.id }
        expect(assigns[:shop]).to eq(@shop)
        expect(response).to render_template('shops/show')
      end

      it 'should update an activity when viewing the shop' do
        get :show, params: { id: @shop.id }
        expect(@shop.versions.last.event).to eq('view')
      end
    end

    describe 'with mime type of JSON/XML' do
      before do
        @shop = FactoryGirl.create(:shop, user: current_user)
        expect(Shop).to receive(:find).and_return(@shop)
      end

      it 'should render the requested shop as json' do
        expect(@shop).to receive(:to_json).and_return('generated JSON')

        request.env['HTTP_ACCEPT'] = 'application/json'
        get :show, params: { id: 13 }
        expect(response.body).to eq('generated JSON')
      end

      it 'should render the requested shop as xml' do
        expect(@shop).to receive(:to_xml).and_return('generated XML')

        request.env['HTTP_ACCEPT'] = 'application/xml'
        get :show, params: { id: 14 }
        expect(response.body).to eq('generated XML')
      end
    end

    describe 'shop got deleted or otherwise unavailable' do
      it 'should redirect to shop index if the shop got deleted' do
        @shop = FactoryGirl.create(:shop, user: current_user)
        @shop.destroy

        get :show, params: { id: @shop.id }
        expect(flash[:warning]).not_to eq(nil)
        expect(response).to redirect_to(shops_path)
      end

      it 'should redirect to shop index if the shop is protected' do
        @private = FactoryGirl.create(:shop, user: FactoryGirl.create(:user), access: 'Private')

        get :show, params: { id: @private.id }
        expect(flash[:warning]).not_to eq(nil)
        expect(response).to redirect_to(shops_path)
      end

      it 'should return 404 (Not Found) JSON error' do
        @shop = FactoryGirl.create(:shop, user: current_user)
        @shop.destroy
        request.env['HTTP_ACCEPT'] = 'application/json'

        get :show, params: { id: @shop.id }
        expect(response.code).to eq('404')
      end

      it 'should return 404 (Not Found) XML error' do
        @shop = FactoryGirl.create(:shop, user: current_user)
        @shop.destroy
        request.env['HTTP_ACCEPT'] = 'application/xml'

        get :show, params: { id: @shop.id }
        expect(response.code).to eq('404')
      end
    end
  end

  context 'responding to GET new' do
    it 'should expose a new shop as @shop and render new' do
      @shop = Shop.new(user: current_user,
                       access: Setting.default_access)
      get :new, xhr: true
      expect(assigns[:shop].attributes).to eq(@shop.attributes)
      expect(response).to render_template('shops/new')
    end
  end

  context 'responding to GET edit' do
    it 'should expose the requested shop as @shop and render edit' do
      @shop = FactoryGirl.create(:shop, id: 13, user: current_user)

      get :edit, params: { id: 13 }, xhr: true
      expect(assigns[:shop]).to eq(@shop)
      expect(assigns[:previous]).to eq(nil)
      expect(response).to render_template('shops/edit')
    end

    it 'should expose previous shop as @previous when necessary' do
      @shop = FactoryGirl.create(:shop, id: 13)
      @previous = FactoryGirl.create(:shop, id: 12)

      get :edit, params: { id: 13, previous: 12 }, xhr: true
      expect(assigns[:previous]).to eq(@previous)
    end

    describe 'shop got deleted or is otherwise unavailable' do
      it 'should reload current page with the flash message if the shop got deleted' do
        @shop = FactoryGirl.create(:shop, user: current_user)
        @shop.destroy

        get :edit, params: { id: @shop.id }, xhr: true
        expect(flash[:warning]).not_to eq(nil)
        expect(response.body).to eq('window.location.reload();')
      end

      it 'should reload current page with the flash message if the shop is protected' do
        @private = FactoryGirl.create(:shop, user: FactoryGirl.create(:user), access: 'Private')

        get :edit, params: { id: @private.id }, xhr: true
        expect(flash[:warning]).not_to eq(nil)
        expect(response.body).to eq('window.location.reload();')
      end
    end

    describe 'previous shop got deleted or is otherwise unavailable' do
      before do
        @shop = FactoryGirl.create(:shop, user: current_user)
        @previous = FactoryGirl.create(:shop, user: FactoryGirl.create(:user))
      end

      it 'should notify the view if previous shop got deleted' do
        @previous.destroy

        get :edit, params: { id: @shop.id, previous: @previous.id }, xhr: true
        expect(flash[:warning]).to eq(nil)
        expect(assigns[:previous]).to eq(@previous.id)
        expect(response).to render_template('shops/edit')
      end

      it 'should notify the view if previous shop got protected' do
        @previous.update_attribute(:access, 'Private')

        get :edit, params: { id: @shop.id, previous: @previous.id }, xhr: true
        expect(flash[:warning]).to eq(nil)
        expect(assigns[:previous]).to eq(@previous.id)
        expect(response).to render_template('shops/edit')
      end
    end
  end

  context 'responding to POST create' do
    describe 'with valid params' do
      it 'should expose a newly created shop as @shop and render create' do
        @shop = FactoryGirl.build(:shop, name: 'TEST SHOP', user: current_user)
        allow(Shop).to receive(:new).and_return(@shop)

        post :create, params: { shop: { name: 'TEST SHOP' } }, xhr: true
        expect(assigns(:shop)).to eq(@shop)
        expect(response).to render_template('shops/create')
      end

      it 'should reload shops to update pagination' do
        @shop = FactoryGirl.build(:shop, user: current_user)
        allow(Shop).to receive(:new).and_return(@shop)

        post :create, params: { shop: { name: 'TEST' } }, xhr: true
        expect(assigns[:shops]).to eq([@shop])
      end
    end

    describe 'with invalid params' do
      it 'should expose a newly created but unsaved shop as @shop and still render create' do
        @shop = FactoryGirl.build(:shop, name: nil, user: nil)
        allow(Shop).to receive(:new).and_return(@shop)

        post :create, params: { shop: {} }, xhr: true
        expect(assigns(:shop)).to eq(@shop)
        expect(response).to render_template('shops/create')
      end
    end
  end

  context 'responding to PUT update' do
    describe 'with valid params' do
      it 'should update the requested shop, and render update' do
        @shop = FactoryGirl.create(:shop, id: 13, name: 'Hello people')

        put :update, params: { id: 13, shop: { name: 'TEST' } }, xhr: true
        expect(@shop.reload.name).to eq('TEST')
        expect(assigns(:shop)).to eq(@shop)
        expect(response).to render_template('shops/update')
      end

      it 'should update shop permissions when sharing with specific users' do
        @shop = FactoryGirl.create(:shop, id: 13, access: 'Public')

        put :update, params: { id: 13, shop: { name: 'TEST', access: 'Shared', user_ids: [7, 8] } }, xhr: true
        expect(assigns[:shop].access).to eq('Shared')
        expect(assigns[:shop].user_ids.sort).to eq([7, 8])
      end
    end

    describe 'shop got deleted or otherwise unavailable' do
      it 'should reload current page is the shop got deleted' do
        @shop = FactoryGirl.create(:shop, user: current_user)
        @shop.destroy

        put :update, params: { id: @shop.id }, xhr: true
        expect(flash[:warning]).not_to eq(nil)
        expect(response.body).to eq('window.location.reload();')
      end

      it 'should reload current page with the flash message if the shop is protected' do
        @private = FactoryGirl.create(:shop, user: FactoryGirl.create(:user), access: 'Private')

        put :update, params: { id: @private.id }, xhr: true
        expect(flash[:warning]).not_to eq(nil)
        expect(response.body).to eq('window.location.reload();')
      end
    end

    describe 'with invalid params' do
      it 'should not update the requested shop but still expose the requested shop as @shop, and render update' do
        @shop = FactoryGirl.create(:shop, id: 13, name: 'TEST')

        put :update, params: { id: 13, shop: { name: nil } }, xhr: true
        expect(assigns(:shop).reload.name).to eq('TEST')
        expect(assigns(:shop)).to eq(@shop)
        expect(response).to render_template('shops/update')
      end
    end
  end

  context 'responding to DELETE destroy' do
    before do
      @shop = FactoryGirl.create(:shop, user: current_user)
    end

    describe 'AJAX request' do
      it 'should destroy the requested shop and render destroy' do
        @another_shop = FactoryGirl.create(:shop, user: current_user)
        delete :destroy, params: { id: @shop.id }, xhr: true

        expect { Shop.find(@shop.id) }.to raise_error(ActiveRecord::RecordNotFound)
        expect(assigns[:shops]).to eq([@another_shop])
        expect(response).to render_template('shops/destroy')
      end

      it 'should try previous page and render index action if current page has no shops' do
        session[:shops_current_page] = 13

        delete :destroy, params: { id: @shop.id }, xhr: true
        expect(session[:shops_current_page]).to eq(12)
        expect(response).to render_template('shops/index')
      end

      it 'should render index action when deleting last shop' do
        session[:shops_current_page] = 1

        delete :destroy, params: { id: @shop.id }, xhr: true
        expect(session[:shops_current_page]).to eq(1)
        expect(response).to render_template('shops/index')
      end

      context 'shop got deleted or otherwise unavailable' do
        it 'should reload current page is the shop got deleted' do
          @shop = FactoryGirl.create(:shop, user: current_user)
          @shop.destroy

          delete :destroy, params: { id: @shop.id }, xhr: true
          expect(flash[:warning]).not_to eq(nil)
          expect(response.body).to eq('window.location.reload();')
        end

        it 'should reload current page with the flash message if the shop is protected' do
          @private = FactoryGirl.create(:shop, user: FactoryGirl.create(:user), access: 'Private')

          delete :destroy, params: { id: @private.id }, xhr: true
          expect(flash[:warning]).not_to eq(nil)
          expect(response.body).to eq('window.location.reload();')
        end
      end
    end

    describe 'HTML request' do
      it 'should redirect to Shops index when an shop gets deleted from its landing page' do
        delete :destroy, params: { id: @shop.id }

        expect(flash[:notice]).not_to eq(nil)
        expect(response).to redirect_to(shops_path)
      end

      it 'should redirect to shop index with the flash message is the shop got deleted' do
        @shop = FactoryGirl.create(:shop, user: current_user)
        @shop.destroy

        delete :destroy, params: { id: @shop.id }
        expect(flash[:warning]).not_to eq(nil)
        expect(response).to redirect_to(shops_path)
      end

      it 'should redirect to shop index with the flash message if the shop is protected' do
        @private = FactoryGirl.create(:shop, user: FactoryGirl.create(:user), access: 'Private')

        delete :destroy, params: { id: @private.id }
        expect(flash[:warning]).not_to eq(nil)
        expect(response).to redirect_to(shops_path)
      end
    end
  end

  context 'responding to PUT attach' do
    describe 'opportunities' do
      before do
        @model = FactoryGirl.create(:shop)
        @attachment = FactoryGirl.create(:opportunity, account: @model.account)
      end
      it_should_behave_like('attach')
    end

    describe 'contacts' do
      before do
        @model = FactoryGirl.create(:shop)
        @attachment = FactoryGirl.create(:contact, account: @model.account)
      end
      it_should_behave_like('attach')
    end
  end

  context 'responding to POST discard' do
    describe 'contacts' do
      before do
        @attachment = FactoryGirl.create(:contact)
        @model = FactoryGirl.create(:shop)
        @model.contacts << @attachment
      end
      it_should_behave_like('discard')
    end

    describe 'opportunities' do
      before do
        @attachment = FactoryGirl.create(:opportunity)
        @model = FactoryGirl.create(:shop)
        @model.opportunities << @attachment
      end
      it_should_behave_like('discard')
    end
  end

  context 'responding to POST auto_complete' do
    before do
      @auto_complete_matches = [FactoryGirl.create(:shop, name: 'Hello World', user: current_user)]
    end

    it_should_behave_like('auto complete')
  end

  context 'responding to GET redraw' do
    it 'should save user selected shops preference' do
      get :redraw, params: { per_page: 13, view: 'brief', sort_by: 'name' }, xhr: true
      expect(current_user.preference[:shops_per_page]).to eq('13')
      expect(current_user.preference[:shops_index_view]).to eq('brief')
      expect(current_user.preference[:shops_sort_by]).to eq('shops.name ASC')
    end

    it 'should reset current page to 1' do
      get :redraw, params: { per_page: 13, view: 'brief', sort_by: "name" }, xhr: true
      expect(session[:shops_current_page]).to eq(1)
    end

    it 'should select @shops and render index' do
      @shops = [
        FactoryGirl.create(:shop, name: 'One', user: current_user),
        FactoryGirl.create(:shop, name: 'Two', user: current_user)
      ]

      get :redraw, params: { per_page: 1, sort_by: 'name' }, xhr: true
      expect(assigns(:shops)).to eq([@shops.first])
      expect(response).to render_template('shops/index')
    end
  end
end
