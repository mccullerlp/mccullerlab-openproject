#-- copyright
# OpenProject is an open source project management software.
# Copyright (C) 2012-2023 the OpenProject GmbH
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2013 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See COPYRIGHT and LICENSE files for more details.
#++

require 'support/pages/page'
require_relative './board_page'

module Pages
  class BoardIndex < Page
    attr_reader :project

    def initialize(project = nil)
      @project = project
    end

    def visit!
      if project
        visit project_work_package_boards_path(project)
      else
        visit work_package_boards_path
      end
    end

    def expect_editable(editable)
      # Editable / draggable check
      expect(page).to have_conditional_selector(editable, '.buttons a.icon-delete')
      # Create button
      expect(page).to have_conditional_selector(editable, '.toolbar-item a', text: 'Board')
    end

    def expect_board(name, present: true)
      expect(page).to have_conditional_selector(present, 'td.name', text: name)
    end

    def create_board(action: nil, expect_empty: false, via_toolbar: false)
      if via_toolbar
        page.find('[data-qa-selector="sidebar--create-board-button"]').click
      else
        page.find('.toolbar-item a', text: 'Board').click
      end

      text = action == nil ? 'Basic' : action.to_s[0..5]
      find('[data-qa-selector="op-tile-block-title"]', text:).click

      if expect_empty
        expect(page).to have_selector('.boards-list--add-item-text', wait: 10)
        expect(page).not_to have_selector('.boards-list--item')
      else
        expect(page).to have_selector('.boards-list--item', wait: 10)
      end

      ::Pages::Board.new ::Boards::Grid.last
    end

    def open_board(board)
      page.find('td.name a', text: board.name).click
      wait_for_reload if using_cuprite?
      ::Pages::Board.new board
    end
  end
end
