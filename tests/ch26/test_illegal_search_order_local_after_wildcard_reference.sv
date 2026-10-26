/*
:name: test_illegal_search_order_local_after_wildcard_reference
:description: A reference through a wildcard import imports the name into the scope of the import, here a package, so a later local declaration of that name in the package is an error (IEEE 1800-2023 Section 26.5)
:tags: ch26
:type: elaboration
:lrm: 1800-2023 26.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the package sw_user declares base after its wildcard import of sw_q was used to resolve base
:expected_stderr_regex: ^(?![^\n]*(?i:unsupported|not supported|not implemented|syntax error|invalid module))[^\n]*test_illegal_search_order_local_after_wildcard_reference\.sv:(?:30|32):(?:\d+:)?[^\n]*(?i:import[^\n]*(?:collid|conflict)|already[^\n]*import)
*/
// IEEE 1800-2023 §26.5: when a scope has a wildcard import, a reference to an
// identifier that is not otherwise defined and that the package declares
// imports that identifier into the scope of the import statement; declaring
// the same identifier later in that scope is an error. In the package sw_user
// the initializer of twice resolves base through the wildcard import of sw_q,
// and base is then declared locally. The name spare of sw_q is never
// referenced, so declaring it locally is legal.
// The 5.052 release of Verilator accepts the design.

package sw_q;
  localparam int base = 4;
  localparam int spare = 5;
endpackage

package sw_user;
  import sw_q::*;
  localparam int twice = 2 * base;
  localparam int spare = 6;
  localparam int base = 9;   // illegal: base was imported from sw_q by the reference above
endpackage

module test_illegal_search_order_local_after_wildcard_reference;
  initial $display("%0d %0d", sw_user::twice, sw_user::spare);
endmodule
