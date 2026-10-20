/*
:name: test_illegal_wildcard_import_conflict
:description: A name that two wildcard imports both provide cannot be referenced (IEEE 1800-2023 Section 26.3)
:tags: ch26
:type: elaboration
:lrm: 1800-2023 26.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: limit is referenced while the wildcard imports of p and q both provide it
:expected_stderr_regex: test_illegal_wildcard_import_conflict\.sv:29:
*/
// IEEE 1800-2023 §26.3: when wildcard imports of two packages in one scope both
// provide a name, a reference that would match it is illegal. Both p and q
// declare limit.

package p;
  int limit = 1;
endpackage

package q;
  int limit = 2;
endpackage

module test_illegal_wildcard_import_conflict;
  import p::*;
  import q::*;
  initial $display("%0d", limit);   // illegal: p::limit or q::limit
endmodule
