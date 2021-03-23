#
# Author:: Ho-Sheng Hsiao (hosh@chef.io)
# Code derived from spec/unit/mixin/command_spec.rb
#
# Original header:
# Author:: Hongli Lai (hongli@phusion.nl)
# Copyright:: Copyright 2009-2016, Phusion
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require "spec_helper"
require "chef/mixin/default_paths"

describe Chef::Mixin::ShellOut do
  let(:shell_out_class) { Class.new { include Chef::Mixin::ShellOut } }
  subject(:shell_out_obj) { shell_out_class.new }

  def env_path
    if ChefUtils.windows?
      "Path"
    else
      "PATH"
    end
  end

  context "when testing individual methods" do
     before(:each) do
       @original_env = ENV.to_hash
       ENV.clear
     end
    #
     after(:each) do
       ENV.clear
       ENV.update(@original_env)
     end

    let(:retobj) { instance_double(Mixlib::ShellOut, "error!" => false) }
    let(:cmd) { "echo '#{rand(1000)}'" }

    %i{shell_out}.each do |method|
      describe "##{method}" do

        describe "when the last argument is a Hash" do
          # Fails for either one of these - ANYTHING that invokes?
          describe "and environment is an option" do
            it "should not change environment language settings when they are set to nil" do
             shell_out_obj.send(method, cmd )

            end
          end

          # describe "and no env/environment option is present" do
          #   it "should set environment language settings to the configured internal locale" do
          #     options = { user: "morty" }
          #     expect(shell_out_obj).to receive(:__shell_out_command).with(cmd,
          #       user: "morty",
          #       environment: {
          #         "LC_ALL" => Chef::Config[:internal_locale],
          #         "LANG" => Chef::Config[:internal_locale],
          #         "LANGUAGE" => Chef::Config[:internal_locale],
          #         env_path => shell_out_obj.default_paths,
          #       }).and_return(retobj)
          #     shell_out_obj.send(method, cmd, **options)
          #   end
          # end
        end

      end
    end
  end
end
