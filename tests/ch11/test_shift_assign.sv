/*
:name: test_shift_assign
:description: Test shift compound assignment (IEEE 1800-2023 Section 11.4.1)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_shift_assign.expected
*/
// Test shift compound assignment (IEEE 1800-2023 Section 11.4.1)

module test_shift_assign;
  logic [7:0] a;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: <<= operator
    a = 8'h01;
    a <<= 4;
    if (a == 8'h10) pass_count++;

    // Test 2: >>= operator
    a = 8'h80;
    a >>= 4;
    if (a == 8'h08) pass_count++;

    // Test 3: Multiple shifts
    a = 8'h0F;
    a <<= 2;
    a >>= 1;
    if (a == 8'h1E) pass_count++;

    $display("Shift assign tests: %0d/3 passed", pass_count);
    if (pass_count == 3) begin
      $display("PASS: Shift assign tests");
    end else begin
      $display("FAIL: Some shift assign tests failed");
    end
  end
endmodule
