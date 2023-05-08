require "bundler/setup"
require "bundler/gem_tasks"
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

begin
  require "bump/tasks"
  Bump.replace_in_default = Dir["gemfiles/**.lock"]
rescue LoadError # not available in gemfiles/
end

desc "Run all tests"
task default: :spec

desc "Update all dependencies"
task :update do
  require "open-uri"

  Dir["lib/maxitest/vendor/*"].each do |file|
    parts = File.read(file).split(%r{(# https://.*)})

    parts = [parts[0].strip] + parts[1..-1].each_slice(2).map do |url, section|
      do_not_modify = "generated by rake update, do not modify"
      code = URI.open(url.sub("# ", "")).read.gsub(/require .*?\n/, "").strip
      code = "=begin\n#{code}\n=end" if url.include?("LICENSE")

      if url.end_with?("/testrbl.rb")
        # nest under Maxitest to avoid collision
        code = "module Maxitest\n#{code.gsub(/^/, "  ").gsub(/^\s+$/, "")}\nend"
      elsif url.end_with?("/line_plugin.rb")
        # replace ruby with mtest
        raise unless code.sub!(%{output = "ruby \#{file} -l \#{line}"}, %{output = "mtest \#{file}:\#{line}"})
      elsif url.end_with?('/around/spec.rb')
        # do not fail with resume for nill class when before was never called
        # for example when putting <% raise %> into a fixture file
        raise unless code.sub!(%{fib.resume unless fib == :failed}, %{fib.resume if fib && fib != :failed})
      elsif url.end_with?('/rg_plugin.rb')
        # support disabling/enabling colors
        # https://github.com/blowmage/minitest-rg/pull/15
        raise unless code.sub!(
          %(opts.on "--rg", "Add red/green to test output." do\n      RG.rg!),
          %(opts.on "--[no-]rg", "Add red/green to test output." do |bool|\n      RG.rg! bool),
        )
        raise unless code.sub!(
          %(    def self.rg!\n      @rg = true),
          %(    def self.rg!(bool = true)\n      @rg = bool),
        )
        raise unless code.sub!(
          "reporter.reporters.grep(Minitest::Reporter).each do |rep|\n        rep.io = io if rep.io.tty?",
          "reporter.reporters.grep(Minitest::Reporter).each do |rep|\n        rep.io = io"
        )
        raise unless code.sub!(
          "MiniTest",
          "Minitest",
        )
      end

      "#{url}\n# BEGIN #{do_not_modify}\n#{code.strip}\n#END #{do_not_modify}"
    end

    File.write(file, parts.reject(&:empty?).join("\n\n") << "\n")
  end
end

task :bundle do
  extra = ENV["EXTRA"]
  Bundler.with_original_env do
    Dir["gemfiles/*.gemfile"].each { |gemfile| sh "BUNDLE_GEMFILE=#{gemfile} bundle #{extra}" }
  end
end
