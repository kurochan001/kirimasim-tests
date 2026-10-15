/*
:name: test_wire_init
:description: Test wire with initialization (IEEE 1800-2023 Section 6.7)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.7 10.3.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_wire_init.expected
*/
// Test wire with initialization (IEEE 1800-2023 Section 6.7)

module test_wire_init;
  wire [7:0] w1 = 8'hAB;
  wire [7:0] w2;
  logic [7:0] driver;
  int pass_count;

  assign w2 = driver;

  initial begin
    pass_count = 0;

    // Test 1: Wire init value. The net declaration assignment is a continuous
    // assignment, so wait before reading it (its order against this initial
    // block at time 0 is not defined: 4.7).
    #1;
    if (w1 == 8'hAB) pass_count++;

    // Test 2: Undriven wire
    driver = 8'hCD;
    #1;
    if (w2 == 8'hCD) pass_count++;

    // Test 3: Wire update
    driver = 8'hEF;
    #1;
    if (w2 == 8'hEF) pass_count++;

    // Test 4: Wire constant
    if (w1 == 8'hAB) pass_count++;

    $display("Wire init tests: %0d/4 passed", pass_count);
    if (pass_count == 4) begin
      $display("PASS: Wire init tests");
    end else begin
      $display("FAIL: Some wire init tests failed");
    end
  end
endmodule
