# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
class Admin::SettingsController < Admin::ApplicationController
  before_action only: [:index] do
    set_current_tab('admin/settings')
  end

  # GET /admin/settings
  # GET /admin/settings.xml
  #----------------------------------------------------------------------------
  def index
  end
end
