/*
:name: test_reg_init
:description: Test register initialization (IEEE 1800-2023 Section 6.8)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.8 10.5
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_reg_init.expected
*/
// Test register initialization (IEEE 1800-2023 Section 6.8)

module test_reg_init;
  reg [7:0] r1 = 8'hAA;
  reg [7:0] r2 = 8'hBB;
  logic [7:0] l1 = 8'hCC;
  int i1 = 42;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Reg init value
    if (r1 == 8'hAA) pass_count++;

    // Test 2: Second reg
    if (r2 == 8'hBB) pass_count++;

    // Test 3: Logic init
    if (l1 == 8'hCC) pass_count++;

    // Test 4: Int init
    if (i1 == 42) pass_count++;

    // Test 5: Modify reg
    r1 = 8'hDD;
    if (r1 == 8'hDD) pass_count++;

    $display("Reg init tests: %0d/5 passed", pass_count);
    if (pass_count >= 4) begin
      $display("PASS: Reg init tests");
    end else begin
      $display("FAIL: Some reg init tests failed");
    end
  end
endmodule
