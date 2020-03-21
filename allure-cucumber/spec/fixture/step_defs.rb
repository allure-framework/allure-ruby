# frozen_string_literal: true

Given("a is {int}") do |num|
  @a = num
end

Given("step has a table") do |table|
end

Given("step has a docstring") do |string|
end

And("b is {int}") do |num|
  @b = num
end

And("this step shoud be skipped") do
end

When("I add a to b") do
  @c = @a + @b
end

Then("result is {int}") do |num|
  expect(@c).to eq(num)
end

Then("step fails with simple exception") do
  raise Exception.new("Simple error!")
end
