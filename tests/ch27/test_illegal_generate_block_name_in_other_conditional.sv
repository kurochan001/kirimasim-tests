/*
:name: test_illegal_generate_block_name_in_other_conditional
:description: The alternative blocks of one conditional generate construct can share a name, but a named block cannot reuse the name of a block of another generate construct in the same scope, even when it is not selected (IEEE 1800-2023 Section 27.5)
:tags: ch27
:type: elaboration
:lrm: 1800-2023 27.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the unselected block of the second if-generate construct is named g, like the blocks of the first construct
:expected_stderr_regex: test_illegal_generate_block_name_in_other_conditional\.sv:30:
*/
// IEEE 1800-2023 §27.5: since at most one alternative block of a conditional
// generate construct is instantiated, several blocks of one construct can
// have the same name; a named block shall not have the name of a block of any
// other conditional or loop generate construct in the same scope, even if
// the blocks with that name are not selected. Both alternatives of the first
// construct are named g; the second construct, whose condition is false,
// names its block g as well.
// The 5.052 release of Verilator does not report the name clash; it stops
// at the later reference g.v instead, which does not count.

module test_illegal_generate_block_name_in_other_conditional #(parameter int P = 1);
  if (P == 1) begin : g
    int v = 1;
  end else begin : g
    int v = 2;
  end
  if (P == 2) begin : g   // illegal: g is a block of the first construct
    int w = 3;
  end
  initial $display("%0d", g.v);
endmodule
