# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Meeting do
  context 'create meeting' do
    it 'should create a new instance given valid attributes' do
      account = create(:account)
      user = create(:user)
      assignee = create(:user)
      expect(Meeting.create!(name: 'Meeting',
                             user: user,
                             meeting_type: 'initial_demo',
                             account: account,
                             important: true,
                             meeting_start: Time.current.utc,
                             timezone: 'Greenland',
                             summary: 'Meeting summary',
                             assignee: assignee)).to be_valid
    end

    it 'should be possible to create meeting with the same name' do
      create(:meeting, assignee: create(:user), name: 'Duplication')
      expect { create(:opportunity, name: 'Duplication') }.to_not raise_error
    end
  end

  context 'scopes' do
    before do
      Meeting.delete_all
      create(:meeting, assignee: create(:user), name: 'Upcoming')
      create(:meeting, :done, assignee: create(:user), name: 'Done')
    end
    it 'upcoming meetings' do
      expect(Meeting.upcoming.count).to eq 1
      expect(Meeting.upcoming.sample.name).to eq 'Upcoming'
    end

    it 'done meetings' do
      expect(Meeting.done.count).to eq 1
      expect(Meeting.done.sample.name).to eq 'Done'
    end
  end
end
