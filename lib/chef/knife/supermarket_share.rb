#
# Author:: Christopher Webber (<cwebber@chef.io>)
# Copyright:: Copyright (c) Chef Software Inc.
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

require_relative "../knife"

class Chef
  class Knife
    class SupermarketShare < Knife

      include Chef::Mixin::ShellOut

      deps do
        require_relative "../cookbook_loader"
        require_relative "../cookbook_uploader"
        require_relative "../cookbook_site_streaming_uploader"
        require_relative "../mixin/shell_out"
      end

      banner "knife supermarket share COOKBOOK [CATEGORY] (options)"
      category "supermarket"

      option :cookbook_path,
        short: "-o PATH:PATH",
        long: "--cookbook-path PATH:PATH",
        description: "A colon-separated path to look for cookbooks in.",
        proc: lambda { |o| Chef::Config.cookbook_path = o.split(":") }

      option :dry_run,
        long: "--dry-run",
        short: "-n",
        boolean: true,
        default: false,
        description: "Don't take action, only print what files will be uploaded to Supermarket."

      option :supermarket_site,
        short: "-m SUPERMARKET_SITE",
        long: "--supermarket-site SUPERMARKET_SITE",
        description: "The URL of the Supermarket site.",
        default: "https://supermarket.chef.io"

      def run
      #  shell_out("ls")
      end

      def get_category(cookbook_name)
        data = noauth_rest.get("#{config[:supermarket_site]}/api/v1/cookbooks/#{@name_args[0]}")
        data["category"]
      rescue => e
        return "Other" if e.is_a?(Net::HTTPClientException) && e.response.code == "404"

        ui.fatal("Unable to reach Supermarket: #{e.message}. Increase log verbosity (-VV) for more information.")
        Chef::Log.trace("\n#{e.backtrace.join("\n")}")
        exit(1)
      end

      def do_upload(cookbook_filename, cookbook_category, user_id, user_secret_filename)
        uri = "#{config[:supermarket_site]}/api/v1/cookbooks"

        category_string = Chef::JSONCompat.to_json({ "category" => cookbook_category })

        http_resp = Chef::CookbookSiteStreamingUploader.post(uri, user_id, user_secret_filename, {
          tarball: File.open(cookbook_filename),
          cookbook: category_string,
        })

        res = Chef::JSONCompat.from_json(http_resp.body)
        if http_resp.code.to_i != 201
          if res["error_messages"]
            if /Version already exists/.match?(res["error_messages"][0])
              ui.error "The same version of this cookbook already exists on Supermarket."
              exit(1)
            else
              ui.error (res["error_messages"][0]).to_s
              exit(1)
            end
          else
            ui.error "Unknown error while sharing cookbook"
            ui.error "Server response: #{http_resp.body}"
            exit(1)
          end
        end
        res
      end

      def tar_cmd
        unless @tar_cmd
          @tar_cmd = "tar"
          begin
            # Unix and Mac only - prefer gnutar
            if shell_out("which gnutar").exitstatus.equal?(0)
              @tar_cmd = "gnutar"
            end
            puts "TAR_CMD: #{@tar_cmd}"
          rescue Errno::ENOENT
            puts "OOOPS - ENOENT!"
          end
        end
        @tar_cmd
      end
    end
  end
end
