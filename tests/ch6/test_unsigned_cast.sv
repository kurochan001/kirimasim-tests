/*
:name: test_unsigned_cast
:description: Test unsigned cast (IEEE 1800-2023 Section 6.24)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.24
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_unsigned_cast.expected
*/
// Test unsigned cast (IEEE 1800-2023 Section 6.24)

module test_unsigned_cast;
  logic signed [7:0] signed_val;
  int unsigned_result;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Positive stays positive
    signed_val = 8'sd50;
    unsigned_result = unsigned'(signed_val);
    if (unsigned_result == 50) pass_count++;

    // Test 2: -1 becomes 255
    signed_val = -8'sd1;
    unsigned_result = $unsigned(signed_val) & 8'hFF;
    if (unsigned_result == 255) pass_count++;

    // Test 3: Zero stays zero
    signed_val = 8'sd0;
    unsigned_result = unsigned'(signed_val);
    if (unsigned_result == 0) pass_count++;

    $display("Unsigned cast tests: %0d/3 passed", pass_count);
    if (pass_count == 3) begin
      $display("PASS: Unsigned cast tests");
    end else begin
      $display("FAIL: Some unsigned cast tests failed");
    end
  end
endmodule
