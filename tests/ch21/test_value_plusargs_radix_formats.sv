/*
:name: test_value_plusargs_radix_formats
:description: $value$plusargs converts the rest of a matching plusarg with %d, %h, %o or %b into the given variable (IEEE 1800-2023 Section 21.6)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:args: +dec=42 +hex=ff +oct=17 +bin=1011
:expected_stdout: @test_value_plusargs_radix_formats.expected
*/
// IEEE 1800-2023 §21.6: $value$plusargs looks for a plusarg that begins with
// the text before the format specification, converts the rest of it as the
// specification says and stores the result in the variable. The four
// plusargs hold the same kind of number written in decimal, hexadecimal,
// octal and binary.

module test_value_plusargs_radix_formats;
  int d;
  logic [7:0] h, o, b;

  initial begin
    if ($value$plusargs("dec=%d", d)) $display("dec=%0d", d);
    if ($value$plusargs("hex=%h", h)) $display("hex=%0d", h);
    if ($value$plusargs("oct=%o", o)) $display("oct=%0d", o);
    if ($value$plusargs("bin=%b", b)) $display("bin=%0d", b);
  end
endmodule
