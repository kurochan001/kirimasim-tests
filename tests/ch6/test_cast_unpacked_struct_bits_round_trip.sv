/*
:name: test_cast_unpacked_struct_bits_round_trip
:description: an unpacked structure cast to a packed vector puts its first member in the most significant bits, its fields and array elements in order, and casting back restores it when the vector keeps its 4-state values (IEEE 1800-2023 Section 6.24.1)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.24.1 6.24.3
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_cast_unpacked_struct_bits_round_trip.expected
*/
// IEEE 1800-2023 §6.24.1: a structure can be converted to bits and back
// without losing information. The packed form is the concatenation of the
// members, and of the elements of an unpacked array member, in order, the
// first member in the most significant bits: tag, val, pair[0], pair[1] for
// rec_t (pair is declared [0:1]) and hi, mid[1], mid[0], lo for two_t (mid is
// declared [1:0]). A 4-state structure needs a logic vector to keep its x and
// z bits; cast to a bit vector they become 0 (§6.24.3), and casting back
// gives 0 there. The 2-state two_t goes through a bit vector unchanged.
// Icarus Verilog 13.0 does not support unpacked structures, and Verilator
// 5.052 does not support casts between unpacked structures and vectors
// ("Unsupported: Size-changing cast on non-basic data type").

module test_cast_unpacked_struct_bits_round_trip;
  typedef struct {
    logic [3:0] tag;
    bit [7:0] val;
    logic [3:0] pair [0:1];
  } rec_t;
  typedef logic [19:0] rec4_t;
  typedef bit [19:0] rec2_t;
  typedef struct {
    bit [3:0] hi;
    byte mid [1:0];
    bit [3:0] lo;
  } two_t;
  typedef bit [23:0] two_bits_t;

  rec_t a, b, c;
  rec4_t l;
  rec2_t t;
  two_t p, p2;
  two_bits_t pb;

  initial begin
    a.tag = 4'b1x0z;
    a.val = 8'h5a;
    a.pair[0] = 4'h3;
    a.pair[1] = 4'bz1x0;
    $display("bits: rec=%0d two=%0d", $bits(rec_t), $bits(two_t));
    l = rec4_t'(a);
    b = rec_t'(l);
    $display("4-state to logic: %b", l);
    $display("back: tag=%b val=%b pair=%b,%b", b.tag, b.val, b.pair[0], b.pair[1]);
    t = rec2_t'(a);
    c = rec_t'(t);
    $display("4-state to bit: %b", t);
    $display("back: tag=%b val=%b pair=%b,%b", c.tag, c.val, c.pair[0], c.pair[1]);
    p.hi = 4'ha;
    p.mid[1] = 8'h12;
    p.mid[0] = 8'hfe;
    p.lo = 4'h7;
    pb = two_bits_t'(p);
    p2 = two_t'(pb);
    $display("2-state to bit: %h", pb);
    $display("back: hi=%h mid=%h,%h lo=%h", p2.hi, p2.mid[1], p2.mid[0], p2.lo);
  end
endmodule
