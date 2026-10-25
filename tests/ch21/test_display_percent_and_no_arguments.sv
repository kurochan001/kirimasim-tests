/*
:name: test_display_percent_and_no_arguments
:description: %% in a display string prints one percent sign but is two characters of the literal, $display without arguments ends the line, and $write without arguments prints nothing (IEEE 1800-2023 Section 21.2.1)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.2.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_display_percent_and_no_arguments.expected
*/
// IEEE 1800-2023 §21.2.1: %% in a string literal displays one percent sign
// and takes no argument; unlike a backslash escape, which is one character
// of the literal, %% is two percent characters of it. $display with no
// arguments, with or without empty parentheses, prints only a newline, and
// $write with no arguments prints nothing.
// The first line shows %% before a digit string, before a letter that would
// otherwise be a format and before a real format, which then takes the one
// argument. The second line prints the lengths of the literals "%%" (2) and
// "\\" (1). Then $display and $display() end the lines after "a" and "b",
// while $write and $write() between "c" and "d" add nothing.

module test_display_percent_and_no_arguments;
  string pct = "%%";
  string bsl = "\\";

  initial begin
    $display("[100%%][%%d][%%%0d]", 7);
    $display("len=%0d len=%0d", pct.len(), bsl.len());
    $write("a");
    $display;
    $write("b");
    $display();
    $write("c");
    $write;
    $write();
    $display("d");
  end
endmodule
