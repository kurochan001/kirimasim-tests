/*
:name: test_randsequence_production_names
:description: In a randsequence block each production is named by a production identifier; the start production names the sequence of two further productions, so each of the two named productions runs once and prints its item (IEEE 1800-2023 Section 18.17)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.17 A.9.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_randsequence_production_names.expected
*/
// IEEE 1800-2023 A.9.3: a randsequence production is named by an
// rs_production_identifier, which is an identifier. §18.17: the randsequence
// statement names a start production and each production holds items; a
// production that lists two other productions runs them in order. The start
// production first names the production shown first, then the production
// shown second, so the two code blocks print first and second in that order
// and there is no random choice.
//
// Icarus Verilog 13.0 does not support randsequence; Verilator 5.052 produces
// this output.

module test_randsequence_production_names;
  initial begin
    randsequence (main)
      main: shown_first shown_second;
      shown_first: { $display("first"); };
      shown_second: { $display("second"); };
    endsequence
  end
endmodule
