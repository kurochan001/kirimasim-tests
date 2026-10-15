/*
:name: test_supply_wire
:description: Test supply wires (IEEE 1800-2023 Section 6.6.6)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.6.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_supply_wire.expected
*/
// Test supply wires (IEEE 1800-2023 Section 6.6.6)

module test_supply_wire;
  supply1 vdd;
  supply0 gnd;
  int pass_count;

  initial begin
    pass_count = 0;
    // The supply nets get their values from time-0 events; wait so that
    // reading them does not race with that update (4.7).
    #1;

    // Test 1: Supply1 is always 1
    if (vdd === 1'b1) pass_count++;

    // Test 2: Supply0 is always 0
    if (gnd === 1'b0) pass_count++;

    // Test 3: Expression with supply
    if (vdd & 1'b1) pass_count++;

    // Test 4: OR with supply0
    if (!(gnd | 1'b0)) pass_count++;

    $display("Supply wire tests: %0d/4 passed", pass_count);
    if (pass_count == 4) begin
      $display("PASS: Supply wire tests");
    end else begin
      $display("FAIL: Some supply tests failed");
    end
  end
endmodule
