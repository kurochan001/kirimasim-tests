/*
:name: test_sformat_too_few_arguments_warns
:description: With too few arguments for the format specifications of a format that is only known at run time, $sformat issues a warning and the simulation goes on (IEEE 1800-2023 Section 21.3.3)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sformat_too_few_arguments_warns.expected
:expected_stderr_regex: (?i:\bwarn(?:ing)?\b|%Warning-)
*/
// IEEE 1800-2023 §21.3.3: if $sformat is given too few or too many arguments
// for the format specifications of its format, the tool shall issue a warning
// and continue; only a mismatch that it can find at compile time may be an
// error instead. The format is put together in a string variable at run time,
// with two specifications and one argument. The test checks the messages for a
// warning, but not its wording, and prints only that the next statements ran,
// since the text the call produces is not fixed.

module test_sformat_too_few_arguments_warns;
  string s, fmt;

  initial begin
    fmt = {"%0d", " ", "%0d"};
    $sformat(s, fmt, 1);
    $display("continued after the call");
    #1 $display("continued at time 1");
  end
endmodule
