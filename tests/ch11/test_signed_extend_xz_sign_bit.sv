/*
:name: test_signed_extend_xz_sign_bit
:description: Extending a signed value whose sign bit is x or z fills the new bits with x or z, and arithmetic on it gives all x (IEEE 1800-2023 Section 11.8.4)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.8.4 11.8.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_signed_extend_xz_sign_bit.expected
*/
// IEEE 1800-2023 §11.8.4: when a signed value is extended to a wider signed
// width and its sign bit is x, the new bits are x; when the sign bit is z, they
// are z. An arithmetic operation on a signed value with any x or z bit gives a
// result that is x in every bit. An unsigned value is extended with zeros
// (11.8.2), whatever its top bit is.

module test_signed_extend_xz_sign_bit;
  logic signed [3:0] sx, sz, s1;
  logic [3:0] ux;
  logic signed [7:0] r;
  logic [7:0] ur;

  initial begin
    sx = 4'bx011;
    sz = 4'bz011;
    s1 = 4'b1011;
    ux = 4'bx011;
    r = sx;         $display("signed x sign bit:  %b", r);
    r = sz;         $display("signed z sign bit:  %b", r);
    r = s1;         $display("signed 1 sign bit:  %b", r);
    ur = ux;        $display("unsigned x top bit: %b", ur);
    r = sx + 8'sd1; $display("signed x plus 1:    %b", r);
  end
endmodule
