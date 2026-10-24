/*
:name: test_package_search_order_cases
:description: in scopes with no import, an explicit import, a wildcard import or a local declaration of the name, an unqualified name and package-qualified names resolve as Table 26-1 gives (IEEE 1800-2023 Section 26.5)
:tags: ch26
:type: simulation
:lrm: 1800-2023 26.5 26.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_package_search_order_cases.expected
*/
// IEEE 1800-2023 §26.5, Table 26-1: a package-qualified name such as
// so_e::c or so_e::YES refers to the package in any scope, without an
// import. An unqualified c refers to an explicitly imported c; with only a
// wildcard import of a package that has c, a reference to c imports it; a
// local declaration of c takes precedence over a wildcard candidate, while
// the other candidates of that package stay importable; and an explicit
// import of c takes precedence over the candidate c of a wildcard import.
// Package so_e has c = NO (4) of its enum type with NO = 4 and YES = 5,
// package so_i has c = 7. Each module below is one scope of the table and
// prints the values it gets, at a time of its own. In the module
// so_wildcard_e_explicit_i, the 5.052 release of Verilator gives so_e::c
// (4) instead of the explicitly imported so_i::c.

package so_e;
  typedef enum int {NO = 4, YES = 5} answer_t;
  localparam answer_t c = NO;
endpackage

package so_i;
  localparam int c = 7;
endpackage

module so_explicit_e;
  import so_e::c;
  initial #1 $display("import so_e::c: c=%0d", c);
endmodule

module so_explicit_i;
  import so_i::c;
  initial #2 $display("import so_i::c: c=%0d so_e::c=%0d so_e::YES=%0d", c, so_e::c, so_e::YES);
endmodule

module so_wildcard_i;
  import so_i::*;
  initial #3 $display("import so_i::*: c=%0d so_e::c=%0d so_e::YES=%0d", c, so_e::c, so_e::YES);
endmodule

module so_wildcard_e_explicit_i;
  import so_e::*;
  import so_i::c;
  initial #4 $display("import so_e::*, so_i::c: c=%0d YES=%0d", c, YES);
endmodule

module so_wildcard_e_local;
  import so_e::*;
  localparam int c = 3;
  answer_t v = YES;
  initial #5 $display("import so_e::*, local c: c=%0d v=%0d NO=%0d", c, v, NO);
endmodule

module so_wildcard_e;
  import so_e::*;
  initial #6 $display("import so_e::*: c=%0d", c);
endmodule

module test_package_search_order_cases;
  so_explicit_e u1 ();
  so_explicit_i u2 ();
  so_wildcard_i u3 ();
  so_wildcard_e_explicit_i u4 ();
  so_wildcard_e_local u5 ();
  so_wildcard_e u6 ();
endmodule
