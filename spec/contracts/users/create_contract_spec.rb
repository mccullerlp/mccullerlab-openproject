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

require 'spec_helper'
require 'contracts/shared/model_contract_shared_context'
require_relative 'shared_contract_examples'

RSpec.describe Users::CreateContract do
  include_context 'ModelContract shared context'

  it_behaves_like 'user contract' do
    let(:user) { User.new(attributes) }
    let(:contract) { described_class.new(user, current_user) }
    let(:attributes) do
      {
        firstname: user_firstname,
        lastname: user_lastname,
        login: user_login,
        mail: user_mail,
        password: user_password,
        password_confirmation: user_password_confirmation,
        notification_settings: [NotificationSetting.new]
      }
    end

    context 'when admin' do
      let(:current_user) { build_stubbed(:admin) }

      it_behaves_like 'contract is valid'

      describe 'requires a password set when active' do
        before do
          user.password = nil
          user.password_confirmation = nil
          user.activate
        end

        it_behaves_like 'contract is invalid', password: :blank

        context 'when password is set' do
          before do
            user.password = user.password_confirmation = 'password!password!'
          end

          it_behaves_like 'contract is valid'
        end
      end

      context 'when user limit reached' do
        before do
          allow(OpenProject::Enterprise).to receive(:user_limit_reached?).and_return(true)
        end

        it_behaves_like 'contract is invalid', base: :user_limit_reached
      end
    end
  end
end
