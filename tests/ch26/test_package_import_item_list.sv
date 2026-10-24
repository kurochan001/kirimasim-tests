/*
:name: test_package_import_item_list
:description: package declarations are reached with the scope resolution operator or imported by one import declaration listing explicit and wildcard items separated by commas (IEEE 1800-2023 Section 26.3)
:tags: ch26
:type: simulation
:lrm: 1800-2023 26.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_package_import_item_list.expected
*/
// IEEE 1800-2023 §26.3, Syntax 26-2: a declaration of a package is used
// either through the package scope resolution operator, p::name, or through
// an import declaration, which lists one or more items p::name or p::*
// separated by commas.
// One import declaration of the module lists the explicit item ia::a1 and
// the wildcard item ib::*, so a1, b1 and b2 are used without a qualifier.
// ia::a2 and ic::c1 are reached with the scope resolution operator; ic is
// not imported at all.

package ia;
  localparam int a1 = 1;
  localparam int a2 = 2;
endpackage

package ib;
  localparam int b1 = 3;
  localparam int b2 = 4;
endpackage

package ic;
  localparam int c1 = 5;
endpackage

module test_package_import_item_list;
  import ia::a1, ib::*;

  initial #1 $display("a1=%0d b1=%0d b2=%0d ia::a2=%0d ic::c1=%0d", a1, b1, b2, ia::a2, ic::c1);
endmodule
