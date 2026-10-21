/*
:name: test_vpi_scan_iterators
:description: vpi_scan returns each object of an iteration once and then NULL, two iterators over the same objects advance independently, and an iteration can be nested in another; vpi_iterate returns NULL when there is nothing to iterate (IEEE 1800-2023 Section 38.40)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.40 38.23
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_scan_iterators.c
:expected_stdout: @test_vpi_scan_iterators.expected
*/
// IEEE 1800-2023 §38.40: vpi_scan returns, one at a time, the objects of the
// iteration that vpi_iterate created, and then NULL, after which the iterator
// is no longer valid. §38.23: vpi_iterate returns NULL when the reference
// object has no objects of the type asked for. At the start of the simulation
// the application lists the variables of the top module, scans two iterators
// over them alternately, iterates the variables of each instance while it
// iterates the instances, and iterates the instances of u1, which has none.
// The order of the objects is not fixed, so the names are printed sorted.

module test_vpi_scan_iterators_unit;
  logic p = 1'b0, q = 1'b1;
endmodule

module test_vpi_scan_iterators;
  logic [3:0] c = 4'd1, a = 4'd2, b = 4'd3;

  test_vpi_scan_iterators_unit u2();
  test_vpi_scan_iterators_unit u1();

  initial #1 $display("design: done");
endmodule
