/*
:name: test_illegal_cg_point_type_without_identifier
:description: a coverpoint that specifies a data type has no coverpoint identifier (IEEE 1800-2023 Section 19.5)
:tags: ch19
:type: elaboration
:lrm: 1800-2023 19.5
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the coverpoint of the covergroup gives the data type int without a coverpoint identifier
:expected_stderr_regex: test_illegal_cg_point_type_without_identifier\.sv:27:
*/
// A coverage point may specify a data type, but then it shall also give a
// cover_point_identifier, which names the point. The coverpoint below writes
// the type int and a colon but no identifier, which is the error. Icarus
// Verilog 13.0 does not implement covergroups, so its syntax errors fall on
// every line of the construct. Release 5.052 of the Verilator tool accepts a
// typed coverpoint of the form int name: coverpoint and rejects this one at
// the colon, which is the place this rule makes an error, so its rejection is
// recorded as the oracle.

module test_illegal_cg_point_type_without_identifier;
  int v;

  covergroup cg;
    int : coverpoint v;   // illegal: a type needs an identifier
  endgroup

  cg g = new;
endmodule
