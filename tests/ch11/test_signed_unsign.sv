/*
:name: test_signed_unsign
:description: Test $signed/$unsigned functions (IEEE 1800-2023 Section 11.7)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.7
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_signed_unsign.expected
*/
// Test $signed/$unsigned functions (IEEE 1800-2023 Section 11.7)

module test_signed_unsign;
  logic [7:0] u_val;
  logic signed [7:0] s_val;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Unsigned to signed
    u_val = 8'hFF;  // 255 unsigned
    s_val = $signed(u_val);
    if (s_val == -1) pass_count++;

    // Test 2: Signed to unsigned
    s_val = -1;
    u_val = $unsigned(s_val);
    if (u_val == 8'hFF) pass_count++;

    // Test 3: Positive stays positive
    u_val = 8'd100;
    s_val = $signed(u_val);
    if (s_val == 100) pass_count++;

    // Test 4: Signed positive to unsigned
    s_val = 8'sd50;
    u_val = $unsigned(s_val);
    if (u_val == 50) pass_count++;

    // Test 5: Large unsigned
    u_val = 8'd200;
    s_val = $signed(u_val);
    if (s_val < 0) pass_count++;

    // Test 6: Chain conversion
    u_val = 8'hAB;
    u_val = $unsigned($signed(u_val));
    if (u_val == 8'hAB) pass_count++;

    $display("Signed/unsigned tests: %0d/6 passed", pass_count);
    if (pass_count == 6) begin
      $display("PASS: Signed/unsigned tests");
    end else begin
      $display("FAIL: Some signed/unsigned tests failed");
    end
  end
endmodule
