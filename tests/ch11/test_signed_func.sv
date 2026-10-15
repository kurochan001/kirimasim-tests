/*
:name: test_signed_func
:description: Test $signed (IEEE 1800-2023 Section 11.7)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.7
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_signed_func.expected
*/
// Test $signed (IEEE 1800-2023 Section 11.7)

module test_signed_func;
  logic [7:0] u;
  logic signed [7:0] s;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Unsigned to signed
    u = 8'hFF;
    s = $signed(u);
    if (s == -1) pass_count++;

    // Test 2: Positive value
    u = 8'h7F;
    s = $signed(u);
    if (s == 127) pass_count++;

    // Test 3: Zero
    u = 8'h00;
    s = $signed(u);
    if (s == 0) pass_count++;

    $display("Signed func tests: %0d/3 passed", pass_count);
    if (pass_count == 3) begin
      $display("PASS: Signed func tests");
    end else begin
      $display("FAIL: Some signed func tests failed");
    end
  end
endmodule
