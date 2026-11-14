/*
:name: test_illegal_pla_descending_memory_word
:description: the words of the personality memory of a PLA task are declared in descending order, while the memory shall be specified in ascending order (IEEE 1800-2023 Section 20.16.3)
:tags: ch20
:type: elaboration
:lrm: 1800-2023 20.16.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the words of the personality memory mem of $async$and$array are declared [2:1]
:expected_stderr_regex: ^(?![^\n]*(?i:unsupported|not supported|not implemented|syntax error|invalid module))[^\n]*test_illegal_pla_descending_memory_word\.sv:(?:30|34):(?:\d+:)?[^\n]*(?i:ascending|descending)
*/
// IEEE 1800-2023 §20.16.3: the personality memory is an array of variables
// whose words are as wide as the number of input terms and whose depth is the
// number of output terms, and the input terms, the output terms and the memory
// shall be specified in ascending order; the memories of the examples in
// 20.16.4 have ascending ranges for both the words and the depth. Here the
// memory has the ascending depth [1:2] but words declared [2:1], while the
// input terms {a1, a2} and the output terms {b1, b2} are ascending, so that is
// the one error; with words declared [1:2] the design is legal. A tool can
// report the declaration of mem or the call.
//
// Icarus Verilog 13.0 compiles the call and says at run time that the task
// is not implemented; the 5.054 release of Verilator rejects the call as an
// unknown task. Neither implements the PLA tasks, so neither checks the
// rule, and the cited clause alone decides this test.

module test_illegal_pla_descending_memory_word;
  logic [2:1] mem [1:2];   // illegal: memory words in descending order
  logic a1, a2;
  logic b1, b2;
  initial begin
    $async$and$array(mem, {a1, a2}, {b1, b2});
  end
endmodule
