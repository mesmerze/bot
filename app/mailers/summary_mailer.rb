# frozen_string_literal: true

class SummaryMailer < ActionMailer::Base
  layout 'mailer'

  def daily_report(admin)
    admin = User.find(admin)

    @opportunities = Opportunity.where('updated_at > ?', 24.hours.ago)
                                .includes(:comments, :account, :user)
                                .group_by(&:assigned_to)

    mail subject: "TS CRM: Daily Summary Report",
         to: admin.email,
         from: "no-reply@tablesolution.com",
         date: Time.now
  end

  def weekly_report(admin)
    admin = User.find(admin)

    @users = User.all.order(:first_name)

    @opportunities = Opportunity.where('created_at > ? and stage not in (?)', 5.days.ago, %w[won lost])
                                .group_by(&:assigned_to)
    @closed_opportunities = Opportunity.where('updated_at > ? and stage in (?)', 5.days.ago, %w[won])
                                       .group_by(&:assigned_to)
    @projected_revenue = revenue_counter(Opportunity.where('stage not in (?)', %w[won lost])
                                                    .pluck(:assigned_to, :amount, :discount, :probability)
                                                    .group_by(&:first))
    @closed_revenue = revenue_counter(Opportunity.where('updated_at > ? and stage  = ?', 5.days.ago, 'won')
                                                 .pluck(:assigned_to, :amount, :discount, :probability)
                                                 .group_by(&:first))
    @live_shops = Shop.where('updated_at > ? and stage = ?', 5.days.ago, 'won')
                      .group_by(&:assigned_to)

    mail subject: "TS CRM: Weekly Summary Report",
         to: admin.email,
         from: "no-reply@tablesolution.com",
         date: Time.now
  end

  def revenue_counter(opportunities)
    opportunities.each do |id, opps|
      opportunities[id] = opps.sum { |_, a, d, p| (a.to_f - d.to_f) * p.to_i / 100 }
    end
  end
end
