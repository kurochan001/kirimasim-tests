/*
:name: test_vector_ranges_bit_order_and_arithmetic
:description: Objects without a range are 1-bit scalars; a range may be descending, ascending, negative or a single index, its left index is always the most significant bit, vectors wrap modulo 2**n, and they are unsigned unless declared signed or connected to a signed port (IEEE 1800-2023 Section 6.9.1)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.9.1 6.9 7.4.1 23.2.2.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vector_ranges_bit_order_and_arithmetic.expected
*/
// IEEE 1800-2023 §6.9: a reg, logic or bit object, or one of a type defined
// as logic, without a range is a 1-bit scalar; with a range it is a vector, a
// packed array of scalars (7.4.1), whose elements are single bits. §6.9.1: the
// two ends of a range can be any integers, negative or zero too, and either
// can be the larger; the left one names the most significant bit and the right
// one the least significant bit. Vectors follow arithmetic modulo 2**n, and
// they are unsigned unless declared signed or connected to a port declared
// signed (23.2.2.1).
// The vectors below are given values whose 1 bits show which index is the
// most significant; the arithmetic results wrap; u4 and s4 hold the same bits.
// The child module declares its port p signed and its net p without signed,
// so p is signed; q is not.
// Oracle checks: the 5.052 release rejects the net declaration of p after its
// signed port declaration, which 23.2.2.1 allows.

module test_vector_ranges_bit_order_and_arithmetic_child(p, q);
  input signed [3:0] p;
  input [3:0] q;
  wire [3:0] p;
  initial #2 $display("ports: p=%0d q=%0d", p, q);
endmodule

module test_vector_ranges_bit_order_and_arithmetic;
  typedef logic one_t;
  logic a;
  bit b;
  reg r;
  one_t t;
  logic [3:0] dn = 4'b0001;
  logic [0:3] up = 4'b0001;
  logic [-1:4] neg = 6'b110000;
  logic [-3:2] mix = 6'b000011;
  logic [5:5] one = 1'b1;
  logic [3:0] m = 4'd15;
  reg [2:0] k;
  bit [7:0] p8;
  logic [3:0] u4 = 4'b1000;
  logic signed [3:0] s4 = 4'b1000;
  wire [3:0] pn = 4'b1000;

  test_vector_ranges_bit_order_and_arithmetic_child c(pn, pn);

  initial begin
    #1 $display("scalars: %0d %0d %0d %0d", $bits(a), $bits(b), $bits(r), $bits(t));
    $display("widths: %0d %0d %0d %0d %0d, element %0d", $bits(dn), $bits(up), $bits(neg),
             $bits(mix), $bits(one), $bits(dn[2]));
    $display("descending: dn[3]=%b dn[0]=%b value=%0d", dn[3], dn[0], dn);
    $display("ascending: up[0]=%b up[3]=%b value=%0d", up[0], up[3], up);
    $display("negative: neg[-1]=%b neg[0]=%b neg[4]=%b value=%0d", neg[-1], neg[0], neg[4], neg);
    $display("mixed: mix[-3]=%b mix[1]=%b mix[2]=%b value=%0d", mix[-3], mix[1], mix[2], mix);
    $display("single index: one[5]=%b", one[5]);
    m = m + 4'd1;
    k = 3'd5 * 3'd3;
    p8 = 8'd200 + 8'd100;
    $display("modulo: m=%0d k=%0d p8=%0d", m, k, p8);
    m = 4'd0 - 4'd1;
    $display("below zero: m=%0d", m);
    $display("signedness: u4=%0d below 0 %0d, s4=%0d below 0 %0d", u4, u4 < 0, s4, s4 < 0);
  end
endmodule
