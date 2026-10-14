/*
:name: test_right_shift
:description: Test right shift (IEEE 1800-2023 Section 11.4.10)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.10
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_right_shift.expected
*/
// Test right shift (IEEE 1800-2023 Section 11.4.10)

module test_right_shift;
  logic [7:0] a, b;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Shift by 1
    a = 8'h02;
    b = a >> 1;
    if (b == 8'h01) pass_count++;

    // Test 2: Shift by 4
    a = 8'h80;
    b = a >> 4;
    if (b == 8'h08) pass_count++;

    // Test 3: Shift with underflow
    a = 8'h01;
    b = a >> 1;
    if (b == 8'h00) pass_count++;

    // Test 4: Shift by 0
    a = 8'hAB;
    b = a >> 0;
    if (b == 8'hAB) pass_count++;

    $display("Right shift tests: %0d/4 passed", pass_count);
    if (pass_count == 4) begin
      $display("PASS: Right shift tests");
    end else begin
      $display("FAIL: Some right shift tests failed");
    end
  end
endmodule
