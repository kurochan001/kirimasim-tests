/*
:name: test_illegal_pla_descending_input_terms
:description: the input terms of a PLA task are a vector declared in descending order, while the input terms shall be specified in ascending order (IEEE 1800-2023 Section 20.16.3)
:tags: ch20
:type: elaboration
:lrm: 1800-2023 20.16.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the input terms of $async$and$array are the net aw, declared [2:1]
:expected_stderr_regex: ^(?![^\n]*(?i:unsupported|not supported|not implemented|syntax error|invalid module))[^\n]*test_illegal_pla_descending_input_terms\.sv:(?:29|34):(?:\d+:)?[^\n]*(?i:ascending|descending)
*/
// IEEE 1800-2023 §20.16.3: the input terms, the output terms and the
// personality memory of a PLA task shall be specified in ascending order, as
// in the examples of 20.16. Here the memory (logic [1:2] mem [1:2]) and the
// output terms (logic [1:2] br) are ascending, and the input terms are the
// net aw, declared [2:1]. The input terms can be nets (20.16), so that is the
// one error; with aw declared [1:2] the design is legal. A tool can report
// the declaration of aw or the call.
//
// Icarus Verilog 13.0 compiles the call and says at run time that the task
// is not implemented; the 5.054 release of Verilator rejects the call as an
// unknown task. Neither implements the PLA tasks, so neither checks the
// rule, and the cited clause alone decides this test.

module test_illegal_pla_descending_input_terms;
  logic [1:2] mem [1:2];
  wire [2:1] aw;   // illegal: input terms in descending order
  logic a1, a2;
  logic [1:2] br;
  assign aw = {a1, a2};
  initial begin
    $async$and$array(mem, aw, br);
  end
endmodule
