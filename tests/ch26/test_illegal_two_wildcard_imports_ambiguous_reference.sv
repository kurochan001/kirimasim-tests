/*
:name: test_illegal_two_wildcard_imports_ambiguous_reference
:description: wildcard imports of two packages that both declare c can be in the same scope, and their other names and p::c can be used, but a direct reference to c is an error (IEEE 1800-2023 Section 26.5)
:tags: ch26
:type: elaboration
:lrm: 1800-2023 26.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: c is a potentially visible name of both wildcard imports p::* and q::*, and they declare different objects, so the direct reference to c is undefined
:expected_stderr_regex: test_illegal_two_wildcard_imports_ambiguous_reference\.sv:41:
*/
// IEEE 1800-2023 §26.5 (Table 26-1): in a scope that has the wildcard import
// q::* of a package declaring c, a wildcard import p::* of another package
// declaring c is allowed, but c is then undefined in the scope, and a direct
// reference to c is an error. Here both imports are in the module; the names
// only_q (only in q) and TRUE (only in p) are imported by their references,
// and the qualified name p::c is legal without an import. Only the direct
// reference to c is illegal. The design is accepted by Verilator 5.054.

package p_pkg;
  int c = 1;
  bit TRUE = 1;
endpackage

package q_pkg;
  int c = 2;
  int only_q = 3;
endpackage

module test_illegal_two_wildcard_imports_ambiguous_reference;
  import p_pkg::*;
  import q_pkg::*;
  int a, b;

  initial begin
    a = only_q;
    b = TRUE;
    a = p_pkg::c;
    b = c;   // illegal
  end
endmodule
