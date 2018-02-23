# frozen_string_literal: true

require 'spec_helper'

describe SummaryMailer do
  before do
    @admin = create(:user, email: 'admin@example.com', admin: true)
    @fresh_opportunity = create(:opportunity, user: @admin, assigned_to: @admin.id, updated_at: Time.current, stage: 'won')
    @old_opportunity = create(:opportunity, user: @admin, assigned_to: @admin.id, updated_at: Time.current - 1.day, stage: 'won')
  end

  context 'daily report' do
    let(:mail) { SummaryMailer.daily_report(@admin.id) }

    it "sets admin 'admin@example.com' as recipient" do
      expect(mail.to).to eq(["admin@example.com"])
    end

    it "includes fresh opportunity in body" do
      expect(mail.body.encoded).to match(@fresh_opportunity.name)
    end

    it "not includes old opportunity in body" do
      expect(mail.body.encoded).not_to match(@old_opportunity.name)
    end
  end

  context 'weekly report' do
    let(:mail) { SummaryMailer.weekly_report(@admin.id) }

    it "sets admin 'admin@example.com' as recipient" do
      expect(mail.to).to eq(["admin@example.com"])
    end

    it "count closed opportunities in body" do
      expect(mail.body.encoded).to match("Opportunities Closed\r\n&#058;\r\n</th>\r\n<td>\r\n2\r\n</td>")
    end

    it "calculate closed opportunities rev in body" do
      revenue = (@old_opportunity.weighted_amount + @fresh_opportunity.weighted_amount).floor.to_s
      expect(mail.body.encoded).to match(revenue)
    end
  end
end
