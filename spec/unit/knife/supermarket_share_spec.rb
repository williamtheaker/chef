
require "spec_helper"
require "chef/knife/supermarket_share"
require "chef/cookbook_uploader"
require "chef/cookbook_site_streaming_uploader"

describe Chef::Knife::SupermarketShare do

  it "should pass now" do
    # ShellOut was a red herring.  Internally it eventually calls Gem.binpath,
    # which is what was hiding the failure in the unmockening, below.
    # class SOT
    #   include Chef::Mixin::ShellOut
    # end

    # class SOT
    #   include Chef::Mixin::ShellOut
    # end
    #    SOT.new.shell_out("ls")



    # This was coming through knife.run, I've moved it here because it's the minimum
    # change to suppress the error. Uncomment it to see it in  action.
    # Gem.dir
  end
end
