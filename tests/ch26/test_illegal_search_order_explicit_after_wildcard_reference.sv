/*
:name: test_illegal_search_order_explicit_after_wildcard_reference
:description: After a reference has imported a name through a wildcard import, an explicit import of the same name from another package in that scope is an error (IEEE 1800-2023 Section 26.5)
:tags: ch26
:type: elaboration
:lrm: 1800-2023 26.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: limit is resolved through the wildcard import of se_q and then explicitly imported from se_p
:expected_stderr_regex: test_illegal_search_order_explicit_after_wildcard_reference\.sv:37:
*/
// IEEE 1800-2023 §26.5: a reference to an identifier that is found only
// through a wildcard import imports it into the scope of the import; a later
// explicit import of the same identifier from a different package in that
// scope then conflicts with it and is an error. The initializer of copy
// imports se_q::limit; the module then imports se_p::limit. The name step,
// which nothing has referenced yet, can still be imported explicitly from
// se_p.
// The 5.052 release of Verilator accepts the design.

package se_p;
  localparam int limit = 1;
  localparam int step = 2;
endpackage

package se_q;
  localparam int limit = 10;
  localparam int step = 20;
endpackage

module test_illegal_search_order_explicit_after_wildcard_reference;
  import se_q::*;
  localparam int copy = limit;
  import se_p::step;
  import se_p::limit;   // illegal: limit was already imported from se_q
  initial $display("%0d %0d", copy, step);
endmodule
