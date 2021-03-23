#
# Author:: David Balatero (dbalatero@gmail.com)
#
# Copyright:: Copyright 2009-2016, David Balatero
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


# this is a global variable we construct of the highest rspec-core version which is installed, using APIs which
# will break out of the bundle -- and done this way so that we can mock all these internal Gem APIs later...
class RspecVersionString
  def self.rspec_version_string
    @rspec_version_string ||= begin
                                stubs = Gem::Specification.send(:installed_stubs, Gem::Specification.dirs, "rspec-core-*.gemspec")
                                stubs.select! { |stub| stub.name == "rspec-core" && Gem::Dependency.new("rspec-core", ">= 0").requirement.satisfied_by?(stub.version) }
                                stubs.max_by(&:version).version.to_s
                              end
  end
end
# This forces us to load the expected version string before any of our tests (in the entire suite)
# execute, ensuring that it's a 'clean' result for the environment.
RspecVersionString.rspec_version_string


require "spec_helper"
require "ostruct"


describe "here we go" do
    it "should pass now" do
      # Uncommenting Gem.dir below does not let it pass, interestingly - though the same
      # action in a different example, located in a different file, will 'Fix' it.
      #    # In other cases (like the same thing done in the hacked supermarket_share_spec
      #    #) Referring to Gem.paths does fix it. AT time of invocation, Gem's @paths is not
      #    initialized in those cases - but it is already initialized when we run this example,
      #    so the corruption has already occurred by the time we're here.
      #Gem.dir
    end
end
# end

describe Chef::Provider::Package::Rubygems::CurrentGemEnvironment do

  let(:logger) { double("Mixlib::Log::Child").as_null_object }
  before do
    @gem_env = Chef::Provider::Package::Rubygems::CurrentGemEnvironment.new
    allow(@gem_env).to receive(:logger).and_return(logger)

    WebMock.disable_net_connect!
  end
  it "determines the installed versions of gems from the source index (part2: the unmockening)" do

    puts "BEFORE WE TEST"
              puts "Gem.path: #{Gem.path}"
              puts "Gem::Specification.dirs: #{Gem::Specification.dirs}"
              puts "PathSupportGem.home: #{Gem::PathSupport.new(ENV).home}"
    expected = ["rspec-core", Gem::Version.new( RspecVersionString.rspec_version_string )]
    #require 'pry'; binding.pry
    actual = @gem_env.installed_versions(Gem::Dependency.new("rspec-core", nil)).map { |spec| [spec.name, spec.version] }
    expect(actual).to include(expected)
  end
end
