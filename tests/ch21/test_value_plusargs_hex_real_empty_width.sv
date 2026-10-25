/*
:name: test_value_plusargs_hex_real_empty_width
:description: $value$plusargs converts the rest of a plusarg as hexadecimal with %h and %x and as a real number in decimal or exponential form with %g, stores zero or an empty string when nothing is left, pads a value with zeros to a wider variable, truncates one that does not fit, and treats a negative value as too large for the variable (IEEE 1800-2023 Section 21.6)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.6
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:args: +hx=Ff +hh=aB +g1=2.5 +g2=1.5e3 +g3=-4E-2 +empty_d= +empty_s= +wide=3f +narrow=1ff +neg=-5
:expected_stdout: @test_value_plusargs_hex_real_empty_width.expected
*/
// IEEE 1800-2023 §21.6: $value$plusargs converts the remainder of the first
// matching plusarg with its format: %h and %x as hexadecimal, %g as a real
// number in decimal or exponential form. If nothing remains, the variable
// gets zero or an empty string. A value smaller than the variable is padded
// with zeros; one that does not fit is truncated; a negative value is taken
// as larger than the variable, so it is truncated rather than padded: -5 in
// a 64-bit variable is fffffffffffffffb. The run gets the plusargs of :args:;
// each variable is set to a marker value first.

module test_value_plusargs_hex_real_empty_width;
  logic [15:0] h16;
  logic [7:0] h8;
  logic [63:0] h64;
  real r;
  int d;
  string s;

  initial begin
    h16 = 16'h1111;
    void'($value$plusargs("hx=%x", h16));
    $display("%%x Ff: %h", h16);
    void'($value$plusargs("hh=%h", h16));
    $display("%%h aB: %h", h16);

    void'($value$plusargs("g1=%g", r));
    $display("%%g 2.5: %0.4f", r);
    void'($value$plusargs("g2=%g", r));
    $display("%%g 1.5e3: %0.4f", r);
    void'($value$plusargs("g3=%G", r));
    $display("%%G -4E-2: %0.4f", r);

    d = 77;
    $display("empty %%d: found=%0d d=%0d", $value$plusargs("empty_d=%d", d) != 0, d);
    s = "full";
    $display("empty %%s: found=%0d s=[%s] len=%0d", $value$plusargs("empty_s=%s", s) != 0, s,
             s.len());

    h16 = 16'h1111;
    void'($value$plusargs("wide=%h", h16));
    $display("3f into 16 bits: %h", h16);
    h8 = 8'h11;
    void'($value$plusargs("narrow=%h", h8));
    $display("1ff into 8 bits: %h", h8);
    h64 = 64'h1111;
    void'($value$plusargs("neg=%d", h64));
    $display("-5 into 64 bits: %h", h64);
  end
endmodule
