/*
:name: test_global_precision_from_timeunit_slash
:description: The global time precision, which vpi_get gives for a NULL object, is the finest precision of the design even when only the precision argument of a timeunit declaration in a submodule sets it (IEEE 1800-2023 Section 3.14.3)
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.14.3 3.14.2.1 3.14.2.2 37.10 38.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_global_precision_from_timeunit_slash.c
:expected_stdout: @test_global_precision_from_timeunit_slash.expected
*/
// IEEE 1800-2023 §3.14.3: the global time precision (the simulation time
// unit) is the smallest of all timeprecision declarations, all precision
// arguments of timeunit declarations and all precisions of `timescale
// directives in the design. §37.10 (detail 7) and §38.6: vpi_get with a NULL
// object returns it for both vpiTimeUnit and vpiTimePrecision.
// The design uses all three kinds: gp_dir follows a `timescale with precision
// 100ps (§3.14.2.1), gp_prec declares timeprecision 10ps and gp_slash
// declares timeunit 10ps / 1fs; (§3.14.2.2); the top module declares
// 1us / 1ns.
// The finest is the precision argument of the timeunit declaration of
// gp_slash, 1fs, so the NULL object gives -15 for both properties, while
// the top module gives its own -6 and -9. The application reads the values
// at the start of the simulation.
// Of the two releases only Icarus Verilog 13.0 follows the clauses here;
// the other one (Verilator 5.052) returns -9, the precision of the top
// module, for vpiTimeUnit of a NULL object.

`timescale 1ns/100ps

module gp_dir;
endmodule

module gp_prec;
  timeunit 1ns;
  timeprecision 10ps;
endmodule

module gp_slash;
  timeunit 10ps / 1fs;
endmodule

module test_global_precision_from_timeunit_slash;
  timeunit 1us;
  timeprecision 1ns;

  gp_dir d();
  gp_prec p();
  gp_slash s();

  initial #1 $display("design: done");
endmodule
