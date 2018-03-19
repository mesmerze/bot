# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path("../acceptance_helper.rb", __FILE__)

feature 'Opportunities', '
  In order to increase sales
  As a user
  I want to manage opportunities
' do
  before :each do
    group = create(:group)
    do_login_if_not_already(first_name: 'Bill', last_name: 'Murray', groups: [group])
    1.upto(3) { |i| create(:opportunity, name: "Opportunity #{i}", stage: 'prospecting', assignee: @user) }
  end

  scenario 'should view a list of opportunities', js: true do
    visit sales_dashboard_page
    expect(page).to have_content('Opportunity 3')
    expect(page).to have_content('Opportunity 1')
    expect(page).to have_content('Opportunity 2')
    expect(page).to have_content('Create Opportunity')
  end

  scenario 'should create a new opportunity', js: true do
    create(:account, name: 'Example Account')
    with_versioning do
      visit sales_dashboard_page
      click_link 'Create Opportunity'
      expect(page).to have_selector('#opportunity_name', visible: true)
      fill_in 'opportunity_name', with: 'My Awesome Opportunity'
      fill_in 'opportunity_probability', with: '100'
      fill_in 'opportunity_amount', with: '1000'
      click_link 'select existing'
      find('#select2-account_id-container').click
      find('.select2-search--dropdown').find('input').set('Example Account')
      sleep(1)
      find('li', text: 'Example Account').click
      expect(page).to have_content('Example Account')
      select 'Myself', from: 'opportunity_assigned_to'
      select 'Prospecting', from: 'opportunity_stage'
      click_link 'Comment'
      fill_in 'comment_body', with: 'This is a very important opportunity.'
      click_button 'Create Opportunity'
      expect(page).to have_content('My Awesome Opportunity')

      find('ul#opportunities').click_link('My Awesome Opportunity')
      expect(page).to have_content('This is a very important opportunity.')

      click_link "My Dashboard"
      expect(page).to have_content("Bill Murray created opportunity My Awesome Opportunity")
      expect(page).to have_content("Bill Murray created comment on My Awesome Opportunity")
    end
  end

  scenario 'should create a new opportunity v2', js: true do
    create(:account, name: 'Example Account')
    with_versioning do
      visit sales_dashboard_page
      click_link 'Create Opportunity'
      expect(page).to have_selector('#opportunity_name', visible: true)
      fill_in 'opportunity_name', with: 'My Awesome Opportunity'
      fill_in 'opportunity_probability', with: '100'
      fill_in 'opportunity_amount', with: '1000'
      fill_in 'account_name', with: 'Example Account'
      select 'Prospecting', from: 'opportunity_stage'
      select 'Upsell', from: 'opportunity_category'
      select 'Myself', from: 'opportunity_assigned_to'
      click_link 'Comment'
      fill_in 'comment_body', with: 'This is a very important opportunity.'
      click_button 'Create Opportunity'
      expect(page).to have_content('My Awesome Opportunity')

      find('ul#opportunities').click_link('My Awesome Opportunity')
      expect(page).to have_content('This is a very important opportunity.')

      click_link "My Dashboard"
      expect(page).to have_content("Bill Murray created opportunity My Awesome Opportunity")
      expect(page).to have_content("Bill Murray created comment on My Awesome Opportunity")
    end
  end

  scenario 'should display correct ammount', js: true do
    with_amount = create(:opportunity, name: 'With Amount', amount: 3000, probability: 90, discount: nil, stage: 'proposal', assignee: @user)
    without_amount = build(:opportunity, name: 'Without Amount', amount: nil, probability: nil, discount: nil, stage: 'proposal', assignee: @user)
    without_amount.save(validate: false)
    with_versioning do
      visit sales_dashboard_page
      click_link 'Long format'
      expect(find("#opportunity_#{with_amount.id}")).to have_content('$3,000 | Probability 90%')
    end
  end

  scenario "remembers the comment field when the creation was unsuccessful", js: true do
    visit sales_dashboard_page
    click_link 'Create Opportunity'
    select 'Prospecting', from: 'opportunity_stage'

    click_link 'Comment'
    fill_in 'comment_body', with: 'This is a very important opportunity.'
    click_button 'Create Opportunity'

    expect(page).to have_field('comment_body', with: 'This is a very important opportunity.')
  end

  scenario 'should view and edit an opportunity', js: true do
    create(:account, name: 'Example Account')
    create(:account, name: 'Other Example Account')
    with_versioning do
      visit sales_dashboard_page
      click_link 'Opportunity 3'
      click_link 'Edit'
      fill_in 'opportunity_name', with: 'An Even Cooler Opportunity'
      select 'Other Example Account', from: 'account_id'
      select 'Analysis', from: 'opportunity_stage'
      click_button 'Save Opportunity'
      expect(page).to have_content('An Even Cooler Opportunity')
      click_link "My Dashboard"
      expect(page).to have_content("Bill Murray updated opportunity An Even Cooler Opportunity")
    end
  end

  scenario 'should delete an opportunity', js: true do
    visit sales_dashboard_page
    click_link 'Opportunity 2'
    click_link 'Delete?'
    expect(page).to have_content('Are you sure you want to delete this opportunity?')
    click_link 'Yes'
    expect(page).not_to have_content("Opportunity 2")
  end

  scenario 'should search for an opportunity', js: true do
    visit sales_dashboard_page
    expect(find('ul#opportunities')).to have_content("Opportunity 2")
    expect(find('ul#opportunities')).to have_content("Opportunity 1")
    fill_in 'query', with: "Opportunity 2"
    expect(find('ul#opportunities')).to have_content("Opportunity 2")
    expect(find('ul#opportunities')).not_to have_content("Opportunity 1")
    fill_in 'query', with: "Opportunity"
    expect(find('ul#opportunities')).to have_content("Opportunity 2")
    expect(find('ul#opportunities')).to have_content("Opportunity 1")
    fill_in 'query', with: "Non-existant opportunity"
    expect(find('ul#opportunities')).not_to have_content("Opportunity 2")
    expect(find('ul#opportunities')).not_to have_content("Opportunity 1")
  end
end
