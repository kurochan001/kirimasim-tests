/*
:name: test_mailbox_basic
:description: Test mailbox (IEEE 1800-2023 Section 15.4)
:tags: ch15
:type: simulation
:lrm: 1800-2023 15.4
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_mailbox_basic.expected
*/
// Test mailbox (IEEE 1800-2023 Section 15.4)

module test_mailbox_basic;
  mailbox #(int) mb;
  int pass_count;
  int val;

  initial begin
    pass_count = 0;

    // Test 1: Create mailbox
    mb = new();
    if (mb != null) pass_count++;

    // Test 2: Put into mailbox
    mb.put(42);
    if (mb.num() == 1) pass_count++;

    // Test 3: Get from mailbox
    mb.get(val);
    if (val == 42) pass_count++;

    // Test 4: Empty after get
    if (mb.num() == 0) pass_count++;

    // Test 5: Multiple puts
    mb.put(10);
    mb.put(20);
    mb.put(30);
    if (mb.num() == 3) pass_count++;

    // Test 6: FIFO order
    mb.get(val);
    if (val == 10) pass_count++;

    $display("Mailbox basic tests: %0d/6 passed", pass_count);
    if (pass_count == 6) begin
      $display("PASS: Mailbox basic tests");
    end else begin
      $display("FAIL: Some mailbox tests failed");
    end
  end
endmodule
