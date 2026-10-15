/*
:name: test_bitop_system_tasks
:description: Test for $countbits, $countones, $onehot, $onehot0, $isunknown system tasks
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.9
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_bitop_system_tasks.expected
*/
// Test for $countbits, $countones, $onehot, $onehot0, $isunknown system tasks
// IEEE 1800-2023 §20.9
module test_bitop_system_tasks;

  // Test data
  logic [7:0] data_all_ones = 8'b11111111;
  logic [7:0] data_all_zeros = 8'b00000000;
  logic [7:0] data_mixed = 8'b10101010;        // 4 ones
  logic [7:0] data_onehot = 8'b00001000;       // exactly 1 one
  logic [7:0] data_two_ones = 8'b00001100;     // 2 ones
  logic [7:0] data_with_x = 8'b1010xxxx;
  logic [7:0] data_with_z = 8'b1010zzzz;

  int test_count = 0;
  int pass_count = 0;

  initial begin
    // Test $countones
    test_count++;
    if ($countones(data_all_ones) == 8) begin
      $display("PASS: $countones all ones = 8");
      pass_count++;
    end else begin
      $display("FAIL: $countones all ones expected 8, got %0d", $countones(data_all_ones));
    end

    test_count++;
    if ($countones(data_all_zeros) == 0) begin
      $display("PASS: $countones all zeros = 0");
      pass_count++;
    end else begin
      $display("FAIL: $countones all zeros expected 0, got %0d", $countones(data_all_zeros));
    end

    test_count++;
    if ($countones(data_mixed) == 4) begin
      $display("PASS: $countones mixed = 4");
      pass_count++;
    end else begin
      $display("FAIL: $countones mixed expected 4, got %0d", $countones(data_mixed));
    end

    // Test $countbits
    test_count++;
    if ($countbits(data_mixed, '1) == 4) begin
      $display("PASS: $countbits mixed, 1 = 4");
      pass_count++;
    end else begin
      $display("FAIL: $countbits mixed, 1 expected 4, got %0d", $countbits(data_mixed, '1));
    end

    test_count++;
    if ($countbits(data_mixed, '0) == 4) begin
      $display("PASS: $countbits mixed, 0 = 4");
      pass_count++;
    end else begin
      $display("FAIL: $countbits mixed, 0 expected 4, got %0d", $countbits(data_mixed, '0));
    end

    // Test $onehot - returns 1 if EXACTLY one bit is high
    test_count++;
    if ($onehot(data_onehot) == 1) begin
      $display("PASS: $onehot one bit = 1");
      pass_count++;
    end else begin
      $display("FAIL: $onehot one bit expected 1, got %0d", $onehot(data_onehot));
    end

    test_count++;
    if ($onehot(data_mixed) == 0) begin
      $display("PASS: $onehot four bits = 0");
      pass_count++;
    end else begin
      $display("FAIL: $onehot four bits expected 0, got %0d", $onehot(data_mixed));
    end

    test_count++;
    if ($onehot(data_all_zeros) == 0) begin
      $display("PASS: $onehot all zeros = 0");
      pass_count++;
    end else begin
      $display("FAIL: $onehot all zeros expected 0, got %0d", $onehot(data_all_zeros));
    end

    // Test $onehot0 - returns 1 if AT MOST one bit is high (0 or 1 bits)
    // IEEE 1800-2023 §20.9: $onehot0 returns true if at most one bit is set
    test_count++;
    if ($onehot0(data_all_zeros) == 1) begin
      $display("PASS: $onehot0 zero bits = 1");
      pass_count++;
    end else begin
      $display("FAIL: $onehot0 zero bits expected 1, got %0d", $onehot0(data_all_zeros));
    end

    test_count++;
    if ($onehot0(data_onehot) == 1) begin
      $display("PASS: $onehot0 one bit = 1");
      pass_count++;
    end else begin
      $display("FAIL: $onehot0 one bit expected 1, got %0d", $onehot0(data_onehot));
    end

    test_count++;
    if ($onehot0(data_two_ones) == 0) begin
      $display("PASS: $onehot0 two bits = 0");
      pass_count++;
    end else begin
      $display("FAIL: $onehot0 two bits expected 0, got %0d", $onehot0(data_two_ones));
    end

    test_count++;
    if ($onehot0(data_all_ones) == 0) begin
      $display("PASS: $onehot0 all ones = 0");
      pass_count++;
    end else begin
      $display("FAIL: $onehot0 all ones expected 0, got %0d", $onehot0(data_all_ones));
    end

    // Test $isunknown
    test_count++;
    if ($isunknown(data_with_x) == 1) begin
      $display("PASS: $isunknown with X = 1");
      pass_count++;
    end else begin
      $display("FAIL: $isunknown with X expected 1, got %0d", $isunknown(data_with_x));
    end

    test_count++;
    if ($isunknown(data_with_z) == 1) begin
      $display("PASS: $isunknown with Z = 1");
      pass_count++;
    end else begin
      $display("FAIL: $isunknown with Z expected 1, got %0d", $isunknown(data_with_z));
    end

    test_count++;
    if ($isunknown(data_mixed) == 0) begin
      $display("PASS: $isunknown no unknown = 0");
      pass_count++;
    end else begin
      $display("FAIL: $isunknown no unknown expected 0, got %0d", $isunknown(data_mixed));
    end

    // Summary
    $display("\n=== Test Summary ===");
    $display("Tests: %0d, Passed: %0d, Failed: %0d", test_count, pass_count, test_count - pass_count);
    if (pass_count == test_count) begin
      $display("PASS: All bitop system tasks tests passed");
    end else begin
      $display("FAIL: Some bitop system tasks tests failed");
    end
    $finish;
  end

endmodule
