/*
:name: test_illegal_generate_region_in_package
:description: a generate region may only be an item of a module, interface, program or checker body, so generate ... endgenerate in a package is illegal (IEEE 1800-2023 Section 27.3)
:tags: ch27
:type: elaboration
:lrm: 1800-2023 27.3
:oracle: spec iverilog@13.0 verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the package region_pkg contains a generate region, and a package body is not one of the containers whose items include a generate region
:expected_stderr_regex: test_illegal_generate_region_in_package\.sv:26:
*/
// IEEE 1800-2023 §27.3: an explicit generate region (generate ...
// endgenerate) may occur only directly as an item of a module, interface,
// program or checker; a package item cannot be a generate region. The
// module uses a generate region around a conditional generate construct,
// which is legal, and the declarations of the package outside the region
// are legal. The only error is the region in the package.
// test_illegal_generate_region_in_loop_block and
// test_illegal_generate_region_in_conditional_block cover a region inside
// a generate block.

package region_pkg;
  localparam int P = 1;
  generate   // illegal
    localparam int Q = 2;
  endgenerate
endpackage

module test_illegal_generate_region_in_package;
  generate
    if (region_pkg::P == 1) begin : g
      int a = 5;
    end
  endgenerate
  initial $display("%0d", g.a);
endmodule
