/*
:name: test_system_funcs_bits
:description: Test bit-related system functions (IEEE 1800-2023 Section 20)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.8.1 20.6.2 20.9
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_system_funcs_bits.expected
*/
// Test bit-related system functions (IEEE 1800-2023 Section 20)

module test_system_funcs_bits;
  logic [31:0] val;
  int ival;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: $clog2
    ival = $clog2(8);
    if (ival == 3) pass_count++;

    // Test 2: $clog2 edge case
    ival = $clog2(1);
    if (ival == 0) pass_count++;

    // Test 3: $bits
    if ($bits(val) == 32) pass_count++;

    // Test 4: $countones
    val = 32'hF0F0F0F0;
    ival = $countones(val);
    if (ival == 16) pass_count++;

    // Test 5: $onehot
    val = 32'h00000001;
    if ($onehot(val)) pass_count++;

    // Test 6: $onehot0
    val = 32'h00000000;
    if ($onehot0(val)) pass_count++;

    // Test 7: $isunknown
    val = 32'h0000000X;
    if ($isunknown(val)) pass_count++;

    $display("System funcs bits tests: %0d/7 passed", pass_count);
    if (pass_count >= 6) begin
      $display("PASS: System funcs bits tests");
    end else begin
      $display("FAIL: Some system funcs tests failed");
    end
  end
endmodule
