/*
:name: test_declaration_initialization_is_not_driver
:description: Static variable initialization occurs before initial procedures and does not follow later source updates (IEEE 1800-2023 Section 10.5)
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.5
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_declaration_initialization_is_not_driver.expected
*/
// IEEE 1800-2023 10.5: The initialized variable captures the initial expression
// once; changing its source cannot continuously drive it.

module test_declaration_initialization_is_not_driver;
  int source = 5;
  int captured = source + 2;
  initial begin
    $display("entry=%0d", captured);
    source = 40;
    #1 $display("after_source_change=%0d", captured);
  end
endmodule
