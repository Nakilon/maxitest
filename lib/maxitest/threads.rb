# tests that leave extra threads running can break other tests in weird ways ... prevent that from happening

raise "Upgrade above minitest 5.0 to use this feature" if Minitest::VERSION.start_with?("5.0")

module Maxitest
  module Threads
    def setup
      @maxitest_threads_before = Thread.list
      super
    end

    def teardown
      super
      found = maxitest_extra_threads
      raise "Test left #{found.size} extra threads (#{found})" if found.any?
    ensure
      maxitest_kill_extra_threads
    end

    # also a helper methods for users
    def maxitest_wait_for_extra_threads
      sleep 0.01 while maxitest_extra_threads.any?
    end

    # also a helper methods for users
    def maxitest_kill_extra_threads
      maxitest_extra_threads.map(&:kill).map(&:join)
    end

    def maxitest_extra_threads
      Thread.list - @maxitest_threads_before
    end
  end
end

# not using prepend since that would clash with webmock
# include works because original setup lives in also included Minitest::LifecycleHooks
Minitest::Test.send :include, Maxitest::Threads
