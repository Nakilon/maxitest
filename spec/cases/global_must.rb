ENV["GLOBAL_MUST"] = "true"
require "./spec/cases/helper"

describe "threads" do
  def assert_it
    1.must_equal 1
  end

  it "can assert normal" do
    assert_it
  end

  it "can assert in threads" do
    result = "not called"
    Thread.new do
      begin
        assert_it
      rescue NoMethodError, RuntimeError, NameError # different errors depending on minitest and ruby version
        result = "error"
      end
    end.join
    result.must_equal "error"
  end
end
