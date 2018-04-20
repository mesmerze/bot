// JS import

// TODO:
/*
  import 'jquery-migrate/dist/jquery-migrate.min'
  have that issue https://github.com/jquery/jquery-migrate/issues/287
*/

// Node modules import
import $ from 'jquery/dist/jquery'; // for some reasons importing jquery.min will break csrf, effects() ...
global.$ = global.jQuery = $;
import 'jquery-ujs/src/rails';
import './js/browser_fix';
import 'webpack-jquery-ui'; // CSS and JS for jquery-ui here
import 'select2';
import 'cocoon/app/assets/javascripts/cocoon';
import 'fullcalendar';

// Vendor js import
import 'javascripts/autocomplete-rails';
import 'javascripts/jquery.disable';
import 'javascripts/jquery_timeago';
import 'javascripts/jquery_ui_datepicker/jquery-ui-timepicker-addon';
import 'javascripts/textarea_autocomplete';
import 'javascripts/ransack/predicates';
import 'javascripts/ransack_ui_jquery/search_form';
import 'javascripts/ransack_ui_jquery/search_form';
import 'javascripts/select2.multi-checkboxes';

// Application js import
import d3 from "d3";
import c3 from 'javascripts/c3';
global.c3 = c3;
import './js/timeago.coffee';
import './js/admin.coffee';
import './js/crm.coffee';
import './js/crm_classes.coffee';
import './js/crm_comments.coffee';
import './js/crm_loginout.coffee';
import './js/crm_select2.coffee';
import './js/crm_sortable.coffee';
import './js/crm_tags.coffee';
import './js/crm_textarea_autocomplete.coffee';
import './js/datepicker.coffee';
import './js/format_buttons.coffee';
import './js/lists.coffee';
import './js/pagination.coffee';
import './js/search.coffee';
import './js/accounts.coffee';
import './js/orgs.coffee';
import './js/tasks.coffee';
import './js/dashboard.coffee';
import './js/kpi.coffee';
import './js/lead_picker.coffee';
import './js/shops_picker.coffee';
import './js/meetings.coffee';
import './js/home.coffee';
import './js/systems.coffee';

import * as ActiveStorage from 'activestorage'
import './js/direct_uploads';
ActiveStorage.start();

// CSS import
import './styles/app';
