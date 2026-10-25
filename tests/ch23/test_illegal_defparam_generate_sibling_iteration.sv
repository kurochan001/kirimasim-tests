/*
:name: test_illegal_defparam_generate_sibling_iteration
:description: A defparam statement in one iteration of a loop generate block cannot change a parameter in another iteration of the same loop (IEEE 1800-2023 Section 23.10.1)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.10.1 27.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the defparam in the iteration g[0] names the parameter of the instance u in the iteration g[1]
:expected_stderr_regex: test_illegal_defparam_generate_sibling_iteration\.sv:31:
*/
// IEEE 1800-2023 §23.10.1: each instance of a generate block is a hierarchy
// of its own, so a defparam statement in one iteration of a loop generate
// construct (§27.4) may not target a parameter in another iteration of the
// same loop. In the iteration i = 0, the conditional block c holds a
// defparam that names g[1].u.P, the instance u of the iteration i = 1.
// Icarus Verilog 13.0 accepts this design. Verilator 5.052 rejects it at the
// defparam only because it does not support a defparam that names an
// element of an array, so it is not listed as an oracle.

module defparam_generate_sibling_leaf;
  parameter int P = 0;
endmodule

module test_illegal_defparam_generate_sibling_iteration;
  for (genvar i = 0; i < 2; i++) begin : g
    defparam_generate_sibling_leaf u();
    if (i == 0) begin : c
      defparam g[1].u.P = 5;   // illegal
    end
  end
endmodule
