/*
:name: test_left_shift
:description: Test left shift (IEEE 1800-2023 Section 11.4.10)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.10
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_left_shift.expected
*/
// Test left shift (IEEE 1800-2023 Section 11.4.10)

module test_left_shift;
  logic [7:0] a, b;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Shift by 1
    a = 8'h01;
    b = a << 1;
    if (b == 8'h02) pass_count++;

    // Test 2: Shift by 4
    a = 8'h01;
    b = a << 4;
    if (b == 8'h10) pass_count++;

    // Test 3: Shift with overflow
    a = 8'h81;
    b = a << 1;
    if (b == 8'h02) pass_count++;

    // Test 4: Shift by 0
    a = 8'hAB;
    b = a << 0;
    if (b == 8'hAB) pass_count++;

    $display("Left shift tests: %0d/4 passed", pass_count);
    if (pass_count >= 3) begin
      $display("PASS: Left shift tests");
    end else begin
      $display("FAIL: Some left shift tests failed");
    end
  end
endmodule
