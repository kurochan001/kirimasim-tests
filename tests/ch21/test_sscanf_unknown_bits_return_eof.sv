/*
:name: test_sscanf_unknown_bits_return_eof
:description: $sscanf returns -1 when its input or its format holds an x or z bit, while the same input and format without unknown bits convert normally (IEEE 1800-2023 Section 21.3.4.3)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.4.3
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_sscanf_unknown_bits_return_eof.expected
*/
// IEEE 1800-2023 §21.3.4.3: if the format or the str argument of $sscanf
// contains unknown bits, x or z, the function returns EOF (-1). The input "12"
// and the format "%d" are 16-bit variables. Without unknown bits the call
// returns 1. With one bit of the input set to x, or to z, and with one bit of
// the format set to z, or to x, it returns -1; only the result is printed.
// Icarus Verilog 13.0 ignores the unknown bits of the input and returns 1.

module test_sscanf_unknown_bits_return_eof;
  logic [15:0] src, fmt;
  int n, a;

  initial begin
    src = "12"; fmt = "%d";
    n = $sscanf(src, fmt, a);
    $display("known: n=%0d a=%0d", n, a);
    src[0] = 1'bx;
    n = $sscanf(src, "%d", a);
    $display("x in input: n=%0d", n);
    src[0] = 1'bz;
    n = $sscanf(src, "%d", a);
    $display("z in input: n=%0d", n);
    src = "12";
    fmt[9] = 1'bz;
    n = $sscanf(src, fmt, a);
    $display("z in format: n=%0d", n);
    fmt[9] = 1'bx;
    n = $sscanf(src, fmt, a);
    $display("x in format: n=%0d", n);
  end
endmodule
