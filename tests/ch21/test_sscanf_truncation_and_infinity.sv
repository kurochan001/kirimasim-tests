/*
:name: test_sscanf_truncation_and_infinity
:description: When the variable of a $sscanf conversion is too small for the value read, its least significant bits are stored, and a real, shortreal or realtime variable gets plus or minus infinity (IEEE 1800-2023 Section 21.3.4.3)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.4.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sscanf_truncation_and_infinity.expected
*/
// IEEE 1800-2023 §21.3.4.3: if an argument is too small to hold the converted
// input, its least significant bits are transferred, but a real, shortreal or
// realtime destination gets +Inf or -Inf. The hexadecimal 12345 into 8 bits
// keeps 45, the decimal 300 into a byte keeps 2c (44), the binary 110101 into
// 4 bits keeps 0101, and the six characters "abcdef" into 3 bytes keep "def".
// 1e400 and -2e999 do not fit a real, and 1e50 does not fit a shortreal; the
// test compares the bits of the result with those of the infinities. The 5.052
// release of Verilator keeps 1e50 in the shortreal variable.

module test_sscanf_truncation_and_infinity;
  logic [7:0] h8;
  byte d8;
  logic [3:0] b4;
  logic [8*3-1:0] s3;
  real r;
  realtime rt;
  shortreal sr;
  int n;

  initial begin
    n = $sscanf("12345", "%h", h8);  $display("h into 8 bits: n=%0d %h", n, h8);
    n = $sscanf("300", "%d", d8);    $display("d into byte: n=%0d %0d", n, d8);
    n = $sscanf("110101", "%b", b4); $display("b into 4 bits: n=%0d %b", n, b4);
    n = $sscanf("abcdef", "%s", s3); $display("s into 3 bytes: n=%0d %s", n, s3);
    n = $sscanf("1e400", "%f", r);
    $display("real 1e400: n=%0d +inf=%0d", n, $realtobits(r) == 64'h7ff0000000000000);
    n = $sscanf("-2e999", "%e", r);
    $display("real -2e999: n=%0d -inf=%0d", n, $realtobits(r) == 64'hfff0000000000000);
    n = $sscanf("3e500", "%g", rt);
    $display("realtime 3e500: n=%0d +inf=%0d", n, $realtobits(rt) == 64'h7ff0000000000000);
    n = $sscanf("1e50", "%f", sr);
    $display("shortreal 1e50: n=%0d +inf=%0d", n, $shortrealtobits(sr) == 32'h7f800000);
  end
endmodule
