/*
:name: test_sscanf_sources_and_string_targets
:description: $sscanf reads from a string literal, a string variable, an integral variable and an unpacked array of bytes, and %s stores a word into an integral variable, an unpacked array of bytes and a string variable (IEEE 1800-2023 Section 21.3.4.3)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.4.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sscanf_sources_and_string_targets.expected
*/
// IEEE 1800-2023 §21.3.4.3: the str argument of $sscanf can be an expression
// of an integral type, an unpacked array of bytes or the string type, and %s
// can store into a variable of an integral type, an unpacked array of bytes or
// the string type. Each kind of source holds two numbers, and each kind of
// target receives one word that fills it exactly. The clause does not say in
// which order the bytes of an unpacked array hold the characters, so the array
// source "4 4" and the array target "abba" read the same in either order.
// Icarus Verilog 13.0 accepts neither an unpacked array of bytes as source nor
// one as target, and the 5.052 release of Verilator cannot build the call with
// the array source.

module test_sscanf_sources_and_string_targets;
  int n, a, b;
  string ss;
  logic [8*3-1:0] si;
  byte sa [0:2];
  logic [8*4-1:0] ti;
  byte ta [0:3];
  string ts;

  initial begin
    n = $sscanf("1 2", "%d %d", a, b);
    $display("literal source: n=%0d a=%0d b=%0d", n, a, b);
    ss = "3 5";
    n = $sscanf(ss, "%d %d", a, b);
    $display("string source: n=%0d a=%0d b=%0d", n, a, b);
    si = "6 7";
    n = $sscanf(si, "%d %d", a, b);
    $display("integral source: n=%0d a=%0d b=%0d", n, a, b);
    sa = '{"4", " ", "4"};
    n = $sscanf(sa, "%d %d", a, b);
    $display("byte array source: n=%0d a=%0d b=%0d", n, a, b);

    n = $sscanf("wxyz", "%s", ti);
    $display("integral target: n=%0d %s", n, ti);
    n = $sscanf("abba", "%s", ta);
    $display("byte array target: n=%0d %c%c%c%c", n, ta[0], ta[1], ta[2], ta[3]);
    n = $sscanf("hello there", "%s", ts);
    $display("string target: n=%0d %s len=%0d", n, ts, ts.len());
  end
endmodule
