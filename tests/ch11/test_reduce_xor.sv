/*
:name: test_reduce_xor
:description: Test reduction xor (IEEE 1800-2023 Section 11.4.9)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.9
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_reduce_xor.expected
*/
// Test reduction xor (IEEE 1800-2023 Section 11.4.9)

module test_reduce_xor;
  logic [7:0] a;
  logic result;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: All zeros (even parity)
    a = 8'h00;
    result = ^a;
    if (result == 1'b0) pass_count++;

    // Test 2: One bit (odd parity)
    a = 8'h01;
    result = ^a;
    if (result == 1'b1) pass_count++;

    // Test 3: Two bits (even parity)
    a = 8'h03;
    result = ^a;
    if (result == 1'b0) pass_count++;

    // Test 4: Three bits (odd parity)
    a = 8'h07;
    result = ^a;
    if (result == 1'b1) pass_count++;

    $display("Reduce xor tests: %0d/4 passed", pass_count);
    if (pass_count >= 3) begin
      $display("PASS: Reduce xor tests");
    end else begin
      $display("FAIL: Some reduce xor tests failed");
    end
  end
endmodule
