# TS Changelog

### 0.4.0

- Fix expected close date bug (#133)
- Refactor: Migrate assets to Webpacker (#131)
- Refactor: Migrate user auth to Devise (#135)
- Improvements to Sales Dashboard (#130)
- Enable Google Oauth login

### 0.3.0

- Fix complete/uncomplete tasks with specific 'due at' time (#115)
- Add orgs/shops relations to tasks and show tasks on landings (#108)
- Hide permissions on entities create/edit (#116)
- Mailer report (#106)
- Fix selecting sales dashboard tab on users profile page
- Compact sales dashboard (#113)
- Add comments to shops landing page (#117)
- Hide comments on Account/Org landings (#118)
- Assigned user are required for opportunities (#121)
- Realign Descriptions & Fix cancel opportunities edit (#126)
- Rename Leads tab to Marketing (#129)
- Multiselect groups and users in KPI report (#127)
- Add task and schedule for projections at the end of every month
- Add task to save projections of demo data
- Auto create intial opportunity (#128)

### 0.2.1

- Fix revenue calculations, fix entities counter
- Fix comment creation

### 0.2.0

- Initial release of KPIs (#100)
- Filter opportunity dashboard by groups and users (#81)
- Allow adding shops to Opportunities (#82)
- Select or create account on leads (#83)
- Opportunity dashboard: add sorting (#84)
- Create opportunity should allow blank campaign (#88)
- Render tasks under appropriate opportunities (#87)
- Add tasks priorities, blockers for opportunities (#99)
- Fix security issues (OS #749)
- Fix oppportunities sort by weighted amount (OS #753)
- Fix sort order of country codes

### 0.1.1

- Fix: Remove incorrect account categories (#79)
- Fix:Change close_on on create (#78)
- Fix:Fix revenue calculations (#80)

## 0.1.0

- Update FFCRM to 0.17.1 (#77)
- Update to Ruby 2.4 (#28)
- AWS config (#33)
- Opportunities: Add fields category, proj. close date, stage 'won/lose' (#17, #62, #70, #77)
- Opportunities: Sets close_on automatically (#70, #77)
- AWS config (#27)
- Add Orgs (#9, #13, #22, #41)
- Add Shops (#30, #45, #57)
- Add Account to Leads (#12, #5, #66)
- Accounts: Add fields (#11, #65)
- Reorder tabs (#10, #72)
- Fix advanced search, fix ajax call (#67)
- Fix delete orgs, select orgs, search by orgs (#49)
- Show tasks for all team members (#46)
- Move setting in settings.default (#31)
