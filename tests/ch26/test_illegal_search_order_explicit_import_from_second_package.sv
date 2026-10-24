/*
:name: test_illegal_search_order_explicit_import_from_second_package
:description: In a scope that already explicitly imports a name from one package, an explicit import of the same name from another package is an error, while the same import in another scope is legal (IEEE 1800-2023 Section 26.5)
:tags: ch26
:type: elaboration
:lrm: 1800-2023 26.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the module imports level explicitly from so2_q and then explicitly from so2_p
:expected_stderr_regex: test_illegal_search_order_explicit_import_from_second_package\.sv:38:
*/
// IEEE 1800-2023 §26.5, Table 26-1: in a scope that contains an explicit
// import of an identifier from one package, an explicit import of the same
// identifier from a different package is illegal. so2_p declares level as an
// enum constant and so2_q as an int. The child module imports so2_p::level on
// its own, which is legal; the top module imports level from so2_q and then
// from so2_p.
// The 5.052 release of Verilator accepts the design.

package so2_p;
  typedef enum {SO2_OFF, SO2_ON} so2_mode_t;
  localparam so2_mode_t level = SO2_ON;
endpackage

package so2_q;
  localparam int level = 5;
endpackage

module so2_child;
  import so2_p::level;
  initial $display("child %0d", level);
endmodule

module test_illegal_search_order_explicit_import_from_second_package;
  import so2_q::level;
  import so2_p::level;   // illegal: level is already imported from so2_q
  so2_child u ();
  initial $display("top %0d", level);
endmodule
