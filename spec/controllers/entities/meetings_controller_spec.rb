# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe MeetingsController do
  before do
    login
    set_current_tab(:meetings)
  end

  describe 'responding to GET index' do
    before do
      @upcoming = create(:meeting, user: current_user, assignee: current_user)
      @done = create(:meeting, :done, assignee: current_user)
    end

    it "should expose all meetings as @meetings_with users and render [index] template" do
      get :index
      expect(assigns[:meetings_with_users]).to eq(current_user.id => [@upcoming])
      expect(response).to render_template('meetings/index')
    end

    it 'should get data for users filter' do
      get :index
      expect(assigns[:users]).to eq([id: @upcoming.user.id, full_name: @upcoming.user.full_name])
    end

    it 'should render upcoming meetings list by default' do
      get :index
      expect(assigns[:meetings_with_users][current_user.id]).to include(@upcoming)
      expect(assigns[:meetings_with_users][current_user.id]).not_to include(@done)
    end

    it 'should render done events if requested' do
      get :index, params: { meetings: 'done' }
      expect(assigns[:meetings_with_users][current_user.id]).not_to include(@upcoming)
      expect(assigns[:meetings_with_users][current_user.id]).to include(@done)
    end

    it 'should filter meetings by user' do
      new_assignee = create :user
      create(:meeting, user: current_user, assignee: new_assignee)

      get :index, params: { users: [new_assignee.id] }
      expect(assigns[:meetings_with_users].keys).not_to include(current_user.id)
      expect(assigns[:meetings_with_users].keys).to include(new_assignee.id)
    end

    it 'should order meetings by start date' do
      another_upcoming = create(:meeting, assignee: current_user, meeting_start: Time.current.utc + 100.days)

      get :index
      expect(assigns[:meetings_with_users]).to eq(current_user.id => [@upcoming, another_upcoming])
    end
  end

  describe 'responding GET new' do
    it 'should expose a new meeting as @meeting and render [new] template' do
      meeting = Meeting.new(user: current_user)

      get :new, xhr: true
      expect(assigns[:meeting].attributes).to eq(meeting.attributes)
      expect(response).to render_template('meetings/new')
    end
  end

  describe 'responding to GET edit' do
    it 'should expose the requested meeting as @meeting and render [edit] template' do
      account = create(:account, user: current_user)
      meeting = create(:meeting, id: 42, user: current_user, assignee: current_user, account: account)

      get :edit, params: { id: 42 }, xhr: true
      expect(assigns[:meeting]).to eq(meeting)
      expect(response).to render_template('meetings/edit')
    end

    it 'should expose previous meeting as @previous when necessary' do
      create(:meeting, id: 42, assignee: current_user)
      previous = create(:meeting, id: 41, assignee: current_user)

      get :edit, params: { id: 42, previous: 41 }, xhr: true
      expect(assigns[:previous]).to eq(previous)
    end

    describe 'meeting got deleted or is otherwise unavailable' do
      it 'should reload current page with the flash message if the meeting got deleted' do
        meeting = create(:meeting, assignee: current_user)
        meeting.destroy

        get :edit, params: { id: meeting.id }, xhr: true
        expect(flash[:warning]).not_to eq(nil)
        expect(response.body).to eq('window.location.reload();')
      end
    end
  end

  describe 'responding to POST create' do
    context 'with valid params' do
      it 'should expose a newly created meeting as @meeting and render create template' do
        meeting = build(:meeting, assignee: current_user)
        allow(Meeting).to receive(:new).and_return(meeting)

        post :create, xhr: true
        expect(assigns(:meeting)).to eq(meeting)
        expect(response).to render_template('meetings/create')
      end
    end

    context 'with invalid params' do
      it 'should expose a newly created but unsaved meeting as @meeting render create template' do
        meeting = build(:meeting, name: nil, assignee: current_user)
        allow(Meeting).to receive(:new).and_return(meeting)

        post :create, xhr: true
        expect(assigns(:meeting)).to eq(meeting)
        expect(response).to render_template('meetings/create')
      end
    end
  end

  describe 'responding to PUT update' do
    context 'with valid params' do
      it 'should update the requested meeting, expose it as @meeting, and render update template' do
        meeting = create(:meeting, id: 42, assignee: current_user)

        put :update, params: { id: 42, meeting: { name: 'Renamed' } }, xhr: true
        expect(meeting.reload.name).to eq('Renamed')
        expect(assigns(:meeting)).to eq(meeting)
        expect(response).to render_template('meetings/update')
      end
    end
    context 'with invalid params' do
      it 'should not update the requested meeting but still expose it as @meeting, and render update template' do
        meeting = create(:meeting, id: 42, name: 'Valid name', assignee: current_user)

        put :update, params: { id: 42, meeting: { name: nil } }, xhr: true
        expect(meeting.reload.name).to eq('Valid name')
        expect(assigns(:meeting)).to eq(meeting)
        expect(response).to render_template('meetings/update')
      end
    end
  end

  describe 'responding to DELETE destroy' do
    it 'should destroy the requested meeting and render destroy template' do
      meeting = create(:meeting, assignee: current_user)
      delete :destroy, params: { id: meeting.id }, xhr: true

      expect { Meeting.find(meeting.id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect(response).to render_template('meetings/destroy')
    end
  end
end
