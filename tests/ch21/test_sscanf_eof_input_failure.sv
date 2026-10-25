/*
:name: test_sscanf_eof_input_failure
:description: When $sscanf reaches the end of its input before a directive has read anything but white space, that directive fails and the result is -1 if nothing was converted yet, while the end met inside a field that was read ends only the following directive, and a mismatch returns the count, 0 when nothing was assigned (IEEE 1800-2023 Section 21.3.4.3)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.4.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sscanf_eof_input_failure.expected
*/
// IEEE 1800-2023 §21.3.4.3: reaching the end of the input ends the conversion.
// If no character of the current directive was read, other than white space
// that may lead it, that directive ends with an input failure; otherwise the
// following directive does. The result is the number of items assigned, but -1
// (EOF) if the input ends before the first conversion or matching failure; a
// matching failure at the start gives 0. Empty input, input of only white
// space, and input that holds only an ordinary character of the format all
// give -1. Input that ends after the first number, also within a field of
// width 3, before the white space or the comma that follows in the format,
// gives 1. A letter where a number is expected gives 0. Values that were not
// assigned keep -1. Icarus Verilog 13.0 returns 0 for the input of only white
// space and for the lone ordinary character, and the 5.052 release
// of Verilator returns -1 also after the first number was assigned.

module test_sscanf_eof_input_failure;
  int n, a, b;

  task automatic show(string what);
    $display("%s: n=%0d a=%0d b=%0d", what, n, a, b);
    a = -1;
    b = -1;
  endtask

  initial begin
    a = -1; b = -1;
    n = $sscanf("", "%d", a);         show("empty");
    n = $sscanf("   ", "%d", a);      show("white space only");
    n = $sscanf("x", "x%d", a);       show("literal then end");
    n = $sscanf("12", "%d %d", a, b); show("end before second");
    n = $sscanf("12", "%3d%d", a, b); show("end inside width");
    n = $sscanf("12", "%d,%d", a, b); show("end before comma");
    n = $sscanf("12 ", "%d %d", a, b); show("end after white space");
    n = $sscanf("ab", "%d", a);       show("mismatch first");
    n = $sscanf("3 b", "%d %d", a, b); show("mismatch second");
  end
endmodule
