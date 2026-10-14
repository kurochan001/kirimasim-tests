/*
:name: test_unsigned_func
:description: Test $unsigned (IEEE 1800-2023 Section 11.7)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.7
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_unsigned_func.expected
*/
// Test $unsigned (IEEE 1800-2023 Section 11.7)

module test_unsigned_func;
  logic signed [7:0] s;
  logic [7:0] u;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Negative to unsigned
    s = -1;
    u = $unsigned(s);
    if (u == 8'hFF) pass_count++;

    // Test 2: Positive value
    s = 8'sh7F;
    u = $unsigned(s);
    if (u == 8'h7F) pass_count++;

    // Test 3: Zero
    s = 0;
    u = $unsigned(s);
    if (u == 0) pass_count++;

    $display("Unsigned func tests: %0d/3 passed", pass_count);
    if (pass_count == 3) begin
      $display("PASS: Unsigned func tests");
    end else begin
      $display("FAIL: Some unsigned func tests failed");
    end
  end
endmodule
