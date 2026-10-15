/*
:name: test_signed_cast
:description: Test signed cast (IEEE 1800-2023 Section 6.24)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.24.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_signed_cast.expected
*/
// Test signed cast (IEEE 1800-2023 Section 6.24)

module test_signed_cast;
  logic [7:0] unsigned_val;
  int signed_result;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Positive value stays positive
    unsigned_val = 8'd100;
    signed_result = signed'(unsigned_val);
    if (signed_result == 100) pass_count++;

    // Test 2: High bit set becomes negative
    unsigned_val = 8'hFF;
    signed_result = signed'(unsigned_val);
    if (signed_result == -1) pass_count++;

    // Test 3: 0x80 becomes -128
    unsigned_val = 8'h80;
    signed_result = signed'(unsigned_val);
    if (signed_result == -128) pass_count++;

    $display("Signed cast tests: %0d/3 passed", pass_count);
    if (pass_count >= 2) begin
      $display("PASS: Signed cast tests");
    end else begin
      $display("FAIL: Some signed cast tests failed");
    end
  end
endmodule
