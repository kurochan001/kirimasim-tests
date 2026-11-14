/*
:name: test_illegal_pla_descending_output_terms
:description: the output terms of a PLA task are a variable declared in descending order, while the output terms shall be specified in ascending order (IEEE 1800-2023 Section 20.16.3)
:tags: ch20
:type: elaboration
:lrm: 1800-2023 20.16.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the output terms of $async$and$array are the variable br, declared [2:1]
:expected_stderr_regex: ^(?![^\n]*(?i:unsupported|not supported|not implemented|syntax error|invalid module))[^\n]*test_illegal_pla_descending_output_terms\.sv:(?:30|32):(?:\d+:)?[^\n]*(?i:ascending|descending)
*/
// IEEE 1800-2023 §20.16.3: the input terms, the output terms and the
// personality memory of a PLA task shall be specified in ascending order, as
// in the examples of 20.16. Here the memory (logic [1:2] mem [1:2]) and the
// input terms (the concatenation {a1, a2}) are ascending, and the output
// terms are the variable br, declared [2:1]. Output terms shall be variables
// (20.16), which br is, so that is the one error; with br declared [1:2] the
// design is legal. A tool can report the declaration of br or the call.
//
// Icarus Verilog 13.0 compiles the call and says at run time that the task
// is not implemented; the 5.054 release of Verilator rejects the call as an
// unknown task. Neither implements the PLA tasks, so neither checks the
// rule, and the cited clause alone decides this test.

module test_illegal_pla_descending_output_terms;
  logic [1:2] mem [1:2];
  logic a1, a2;
  logic [2:1] br;   // illegal: output terms in descending order
  initial begin
    $async$and$array(mem, {a1, a2}, br);
  end
endmodule
