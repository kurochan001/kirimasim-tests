/*
:name: test_string_concat_empty_replication
:description: String concatenation and replication preserve an empty operand and runtime repeat count (IEEE 1800-2023 Section 11.4.12.2)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.12.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_concat_empty_replication.expected
*/
// IEEE 1800-2023 11.4.12.2: A string operand makes concatenation a string;
// repetition counts determine the number of complete string copies.
// Oracle checks: Icarus Verilog 13.0 does not build this case.

module test_string_concat_empty_replication;
  string s = "Q";
  string r;
  int n = 3;
  initial begin
    r = {"", {n{s}}, "!"};
    $display("value=%s length=%0d", r, r.len());
  end
endmodule
