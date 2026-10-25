/*
:name: test_illegal_identifier_declared_twice_in_scope
:description: An identifier can be declared at most once in a scope, so a named block cannot declare two variables of the same name (IEEE 1800-2023 Section 23.6)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.6 3.13
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the named block b declares the identifier count twice
:expected_stderr_regex: test_illegal_identifier_declared_twice_in_scope\.sv:24:
*/
// IEEE 1800-2023 §23.6: each node of the hierarchical name tree is a
// separate scope, and an identifier can be declared at most once in a
// scope (§3.13). The named block b declares count twice; the module scope
// also has a count, which is legal because it is another scope.

module test_illegal_identifier_declared_twice_in_scope;
  int count = 0;

  initial begin : b
    int count;
    logic [3:0] count;   // illegal
    count = 1;
  end
endmodule
