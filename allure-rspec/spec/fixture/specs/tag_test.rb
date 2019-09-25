# frozen_string_literal: true

describe "Suite" do
  it(
    "spec",
    tms: "QA-123", tms_2: "QA-124", issue: "BUG-123", issue_2: "BUG-124",
    flaky: true, muted: true, severity: "critical"
  ) do
  end
end
