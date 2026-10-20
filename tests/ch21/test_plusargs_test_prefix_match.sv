/*
:name: test_plusargs_test_prefix_match
:description: $test$plusargs finds a plusarg whose beginning equals the given string, and only then (IEEE 1800-2023 Section 21.6)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:args: +HELLO_WORLD +VERBOSE=3
:expected_stdout: @test_plusargs_test_prefix_match.expected
*/
// IEEE 1800-2023 §21.6: $test$plusargs returns nonzero when the prefix of one
// of the plusargs given to the simulation matches every character of its
// string, and zero otherwise. The run gets +HELLO_WORLD and +VERBOSE=3: HELLO,
// the whole HELLO_WORLD and V are prefixes, while WORLD (inside, not at the
// start) and HELLO_WORLD_X (longer than the plusarg) are not.

module test_plusargs_test_prefix_match;
  task check(string s);
    $display("%s: %0d", s, $test$plusargs(s) != 0);
  endtask

  initial begin
    check("HELLO");
    check("HELLO_WORLD");
    check("HELLO_WORLD_X");
    check("WORLD");
    check("V");
    check("VERBOSE=3");
    check("VERBOSE=4");
  end
endmodule
