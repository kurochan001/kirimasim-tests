/*
:name: test_illegal_search_order_explicit_import_of_local_name
:description: An explicit import of a name that the importing scope declares itself is an error, while a wildcard import of a package with the same name is legal there (IEEE 1800-2023 Section 26.5)
:tags: ch26
:type: elaboration
:lrm: 1800-2023 26.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the module declares count and then explicitly imports sl_p::count
:expected_stderr_regex: test_illegal_search_order_explicit_import_of_local_name\.sv:33:
*/
// IEEE 1800-2023 §26.5, Table 26-1: in a scope that contains a local
// declaration of an identifier, a direct reference to it means the local one,
// and an explicit import of the same identifier from a package is illegal.
// The module declares count, imports sl_q with a wildcard, which is legal and
// leaves count local, and then imports sl_p::count explicitly.
// The 5.052 release of Verilator accepts the design.

package sl_p;
  localparam int count = 1;
endpackage

package sl_q;
  localparam int count = 2;
  localparam int other = 3;
endpackage

module test_illegal_search_order_explicit_import_of_local_name;
  localparam int count = 7;
  import sl_q::*;
  import sl_p::count;   // illegal: count is declared in this scope
  initial $display("%0d %0d", count, other);
endmodule
