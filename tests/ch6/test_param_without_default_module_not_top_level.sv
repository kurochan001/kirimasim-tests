/*
:name: test_param_without_default_module_not_top_level
:description: of the modules that nothing instantiates, those with a value or type parameter without a default are not made top-level instances and their procedures never run, while those whose parameters all have defaults, or that have none, are top-level instances whose procedures run (IEEE 1800-2023 Section 6.20.1)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.20.1 23.3.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_param_without_default_module_not_top_level.expected
*/
// IEEE 1800-2023 §23.3.1: a module that no instantiation statement names is
// a top-level module, which is instantiated implicitly once. §6.20.1 makes
// an exception: when a parameter of a design element has no default value,
// a tool shall not instantiate that design element implicitly.
// Nothing in the design instantiates any of the six modules:
// - the main module, _plain, which has no parameters, and _defaulted, whose
//   value parameter and type parameter both have defaults, are top-level
//   instances; _plain prints at time 1, _defaulted at time 2 with the
//   default values, and the main module at time 3;
// - _no_value has a value parameter without a default, _no_type a type
//   parameter without one, and _mixed a parameter with a default followed
//   by one without; none of them is instantiated, so their initial
//   procedures, which would print at time 0, and the final procedure of
//   _no_value never run.
// A tool that made any of the last three a top-level instance would print
// more lines, or stop because a parameter has no value.
// Oracle checks: the 5.054 release of Verilator makes _no_value a
// top-level instance and stops with an error that Q is never given a
// value.

module test_param_without_default_module_not_top_level_plain;
  initial #1 $display("plain module: runs");
endmodule

module test_param_without_default_module_not_top_level_defaulted
    #(parameter int D = 4, parameter type T = byte) ();
  T v;
  initial #2 $display("defaulted module: D=%0d bits of T=%0d", D, $bits(v));
endmodule

module test_param_without_default_module_not_top_level_no_value #(parameter int Q) ();
  initial $display("no_value module: Q=%0d", Q);
  final $display("no_value module: final runs");
endmodule

module test_param_without_default_module_not_top_level_no_type #(parameter type T) ();
  T v;
  initial $display("no_type module: bits of T=%0d", $bits(v));
endmodule

module test_param_without_default_module_not_top_level_mixed
    #(parameter int A = 1, parameter int B) ();
  initial $display("mixed module: A=%0d B=%0d", A, B);
endmodule

module test_param_without_default_module_not_top_level;
  initial #3 $display("main module: done");
endmodule
