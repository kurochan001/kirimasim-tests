/*
:name: test_illegal_pla_descending_memory
:description: the personality memory of a PLA task is declared in descending order (IEEE 1800-2023 Section 20.16.3)
:tags: ch20
:type: elaboration
:lrm: 1800-2023 20.16.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the personality memory mem of $async$and$array is declared [2:1]
:expected_stderr_regex: ^(?![^\n]*(?i:unsupported|not supported|not implemented|syntax error|invalid module))[^\n]*test_illegal_pla_descending_memory\.sv:(?:18|22):(?:\d+:)?[^\n]*(?i:ascending|descending)
*/
// PLA input terms, output terms and the personality memory shall be
// specified in ascending order. The memory here is declared [2:1].

module test_illegal_pla_descending_memory;
  logic [1:2] mem [2:1];   // illegal: not ascending order
  logic a1, a2;
  logic b1, b2;
  initial begin
    $async$and$array(mem, {a1, a2}, {b1, b2});
  end
endmodule
