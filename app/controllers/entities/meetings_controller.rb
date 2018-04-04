# frozen_string_literal: true

class MeetingsController < EntitiesController
  skip_before_action :set_options

  before_action :filters, only: %i[index destroy]

  def index
    @meetings_with_users = meetings
    @users = User.where(id: @meetings_with_users.keys)
                 .order('first_name')
                 .map { |user| { id: user.id, full_name: user.full_name } }
  end

  def new
    @meeting = Meeting.new(user: current_user)
  end

  def create
    respond_with(@meeting) do |_format|
      @meeting.save
    end
  end

  def edit
    @account = @meeting.account
    if params[:previous].to_s =~ /(\d+)\z/
      @previous = Meeting.find_by_id(Regexp.last_match[1]) || Regexp.last_match[1].to_i
    end
  end

  def update
    respond_with(@meeting) do |_format|
      @meeting.update_attributes(meeting_params)
    end
  end

  def destroy
    @account = @meeting.account
    @meeting.destroy

    respond_with(@meeting) do |format|
      format.js do
        if called_from_index_page?
          @meetings = meetings
          if @meetings.blank?
            render(:index) && return
          end
        else # Called from related asset.
          self.current_page = 1
        end
      end
    end
  end

  def calendar
    @meeting = Meeting.new
    ids = calendar_params[:users]&.map(&:to_i)

    @meetings = Meeting.includes(:account, :assignee)
                       .where('meeting_start >= ? AND meeting_start <= ? AND assigned_to IN (?)', calendar_params[:start], calendar_params[:end], ids)
    @meetings = @meetings.map do |event|
      { title: event.name,
        summary: event.summary,
        account: event.account.name,
        start: helpers.parse_time(event).strftime("%FT%R"),
        end: (helpers.parse_time(event) + 1.hour).strftime("%FT%R"),
        timezone: event.timezone }
    end

    respond_with(@meetings.to_json)
  end

  private

  def calendar_params
    params.permit(:start, :end, users: [])
  end

  def filters
    @view = params.fetch('meetings', 'upcoming')
    @users_filter = params.fetch('users', []).map(&:to_i)
  end

  def meetings
    meetings = Meeting.with_attached_document
                      .includes(:user, :account)
                      .joins(:assignee)
                      .send(@view)
                      .select('users.id as assignee_id, users.first_name, meetings.*')
                      .order('users.first_name, meetings.meeting_start')
                      .group_by(&:assignee_id)
    return meetings if @users_filter.blank?
    meetings.select { |uid, _| @users_filter.include? uid }
  end

  def meeting_params
    return {} unless params[:meeting]
    params.require(:meeting).permit(:user_id, :meeting_type, :name, :account_id, :assigned_to, :meeting_start, :important, :summary, :timezone, :document)
  end
end
