/*
:name: test_package_import_interface_header
:description: A package imported in an interface header is visible in its parameter and port declarations (IEEE 1800-2023 Section 26.4)
:tags: ch26
:type: simulation
:lrm: 1800-2023 26.4 26.3 25.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_package_import_interface_header.expected
*/
// IEEE 1800-2023 §26.4: an import in an interface header, before its port
// list, makes the package items visible in the port declarations and in the
// body. §25.3: the interface ports connect to the module signals. The port
// types come from the package typedef nib_t, and the continuous assignment
// in the interface inverts them.

package ifc_pkg;
  parameter int W = 4;
  typedef logic [W-1:0] nib_t;
endpackage

interface ifc import ifc_pkg::*; (input nib_t i, output nib_t o);
  assign o = ~i;
endinterface

module test_package_import_interface_header;
  logic [3:0] a = 4'h3;
  logic [3:0] b;

  ifc u(.i(a), .o(b));

  initial #1 $display("b=%h", b);
endmodule
