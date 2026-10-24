/*
:name: test_package_explicit_import_only_named
:description: an explicit import makes only the named declaration visible, and importing an enum type does not import its literals (IEEE 1800-2023 Section 26.3)
:tags: ch26
:type: simulation
:lrm: 1800-2023 26.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_package_explicit_import_only_named.expected
*/
// IEEE 1800-2023 §26.3: an explicit import p::name imports only that
// symbol. In particular, importing an enum type does not import the enum
// literals, which can then be reached as p::literal or by importing them as
// well. A name that the module does not import is looked up in the
// compilation unit.
// Package ei declares a = 10, b = 20 and the enum type mode_t with OFF = 1
// and ON = 2; the compilation unit declares b = 50 and ON = 60. The module
// imports ei::a and ei::mode_t only: a is 10, but b and ON are the ones of
// the compilation unit, and the variable m of type mode_t is set from
// ei::ON, which is 2.

localparam int b = 50;
localparam int ON = 60;

package ei;
  typedef enum int {OFF = 1, ON = 2} mode_t;
  localparam int a = 10;
  localparam int b = 20;
endpackage

module test_package_explicit_import_only_named;
  import ei::a;
  import ei::mode_t;
  mode_t m = ei::ON;

  initial #1 $display("a=%0d b=%0d ON=%0d m=%0d", a, b, ON, m);
endmodule
