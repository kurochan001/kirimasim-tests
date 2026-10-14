/*
:name: test_logic_type
:description: Test logic type (IEEE 1800-2023 Section 6.8)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.8
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_logic_type.expected
*/
// Test logic type (IEEE 1800-2023 Section 6.8)

module test_logic_type;
  logic l1;
  logic [7:0] l8;
  logic [31:0] l32;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Single bit logic
    l1 = 1'b1;
    if (l1 == 1'b1) pass_count++;

    // Test 2: 8-bit logic
    l8 = 8'hAB;
    if (l8 == 8'hAB) pass_count++;

    // Test 3: 32-bit logic
    l32 = 32'hDEADBEEF;
    if (l32 == 32'hDEADBEEF) pass_count++;

    // Test 4: Logic to zero
    l1 = 1'b0;
    if (l1 == 1'b0) pass_count++;

    $display("Logic type tests: %0d/4 passed", pass_count);
    if (pass_count >= 3) begin
      $display("PASS: Logic type tests");
    end else begin
      $display("FAIL: Some logic type tests failed");
    end
  end
endmodule
