/*
:name: test_duplicate_cell_last_definition_wins
:description: Two cells with the same name that map to the same library leave the last definition in the library and cause a warning in one compiler invocation (IEEE 1800-2023 Section 33.3.1.1)
:tags: ch33
:type: simulation
:lrm: 1800-2023 33.3.1 33.3.1.1 33.3.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stderr_regex: (?i)warn
:expected_stdout: @test_duplicate_cell_last_definition_wins.expected
*/
// IEEE 1800-2023 §33.3.1.1: "If multiple cells with the same name map to the
// same library, then the last cell encountered shall be written to the
// library." §33.3.3: each cell definition is mapped by the source file it is
// parsed from, and with no library map all cells here are in work (33.3.1).
// The module dcl is defined twice; the second definition is the one written to
// the library, so the instance u runs it and prints "second", and a warning is
// issued because both definitions come from one invocation.
//
// Neither release carries out library mapping for two modules of one name in
// one invocation; both reject the duplicate definition, so :oracle: names the
// standard alone.

module dcl;
  initial $display("first");
endmodule

module dcl;
  initial $display("second");
endmodule

module test_duplicate_cell_last_definition_wins;
  dcl u();

  initial #1 $finish;
endmodule
