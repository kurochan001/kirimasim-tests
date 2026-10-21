/*
:name: test_package_import_interface_header_function
:description: A package imported in an interface header supplies a parameter, a type and a function that the interface ports and a continuous assignment in its body use (IEEE 1800-2023 Sections 26.4 and 26.3)
:tags: ch26
:type: simulation
:lrm: 1800-2023 26.4 26.3 25.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_package_import_interface_header_function.expected
*/
// IEEE 1800-2023 §26.4: an import in an interface header, before the port
// list, makes the package items visible in the port declarations and in the
// interface body. §26.3: the port type ih_t and the function mask() come from
// ih_pkg, and mask() keeps the low two bits in the continuous assignment.
// §25.3: the module connects its own signals to the interface ports.

package ih_pkg;
  parameter int BITS = 3;
  typedef logic [BITS-1:0] ih_t;

  function automatic ih_t mask(ih_t v);
    return v & ih_t'(2'b11);
  endfunction
endpackage

interface masked_if
  import ih_pkg::*;
(
  input ih_t i,
  output ih_t o
);
  assign o = mask(i);
endinterface

module test_package_import_interface_header_function;
  logic [2:0] a;
  logic [2:0] b;

  masked_if u (.i(a), .o(b));

  initial begin
    a = 3'b101;
    #1 $display("mask(101)=%b", b);
    a = 3'b010;
    #1 $display("mask(010)=%b", b);
  end
endmodule
