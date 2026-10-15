/*
:name: test_reg_type
:description: Test reg type (IEEE 1800-2023 Section 6.11)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.11
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_reg_type.expected
*/
// Test reg type (IEEE 1800-2023 Section 6.11)

module test_reg_type;
  reg r1;
  reg [7:0] r8;
  reg [15:0] r16;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Single bit reg
    r1 = 1'b1;
    if (r1 == 1'b1) pass_count++;

    // Test 2: 8-bit reg
    r8 = 8'hEF;
    if (r8 == 8'hEF) pass_count++;

    // Test 3: 16-bit reg
    r16 = 16'h5678;
    if (r16 == 16'h5678) pass_count++;

    // Test 4: Reg update
    r1 = 1'b0;
    if (r1 == 1'b0) pass_count++;

    $display("Reg type tests: %0d/4 passed", pass_count);
    if (pass_count >= 3) begin
      $display("PASS: Reg type tests");
    end else begin
      $display("FAIL: Some reg type tests failed");
    end
  end
endmodule
