/*
:name: test_sscanf_excess_arguments_ignored
:description: $sscanf stores each conversion into the argument in the same position, a suppressed conversion takes no argument, and arguments left over when the format is used up are ignored and keep their values (IEEE 1800-2023 Section 21.3.4.3)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.4.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sscanf_excess_arguments_ignored.expected
*/
// IEEE 1800-2023 §21.3.4.3: the result of each conversion is placed in the
// corresponding argument; a conversion with * has no argument. If the format
// is used up while arguments remain, the remaining arguments are ignored. The
// numbers 1, 2 and 3 are read into a, b and c in order; with %*d the second
// number is dropped and the third goes into b; and with one or two conversions
// for three arguments, the arguments after them keep -1. The case of too few
// arguments, whose behavior is undefined, is not used. The 5.052 release
// of Verilator rejects a call with more arguments than conversions.

module test_sscanf_excess_arguments_ignored;
  int n, a, b, c;

  task automatic show(string what);
    $display("%s: n=%0d a=%0d b=%0d c=%0d", what, n, a, b, c);
    a = -1; b = -1; c = -1;
  endtask

  initial begin
    a = -1; b = -1; c = -1;
    n = $sscanf("1 2 3", "%d %d %d", a, b, c); show("three");
    n = $sscanf("1 2 3", "%d %*d %d", a, b, c); show("suppressed");
    n = $sscanf("1 2 3", "%d %d", a, b, c);     show("two of three");
    n = $sscanf("1 2 3", "%d", a, b, c);        show("one of three");
  end
endmodule
