/*
:name: test_packed_union_size_and_implicit_conversion
:description: logic is one bit, a packed union is as wide as its largest member, packed structs convert implicitly, and a static enum cast is a coercion
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.24.1 6.19.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_packed_union_size_and_implicit_conversion.expected
*/
// IEEE 1800-2023 6.24.1: the size of a logic is one bit and the size of an
// ordinary union is the size of its largest member. Packed types are implicitly
// converted as integral values, so a packed struct can be assigned from an
// integral value. A cast whose operand is not assignment compatible follows
// 6.19.4 for an enum destination; the test casts an out-of-range integral to an
// enum and observes the coerced value without a membership check.
// The standard disagrees with itself on $bits of the unpacked union uun_t.
// 20.6.2 takes the legal types of $bits from 6.24.3, whose bit-stream types
// do not include unions. 6.24.1 gives the size of a union as that of its
// largest member, and its example applies $bits to a structure holding an
// unpacked union. The test follows 6.24.1, the rule written for unions;
// slang, and so kirimasim, follows 6.24.3 and rejects $bits(uun_t).

typedef union {
  logic [7:0] bytev;
  logic [15:0] wordv;
} uun_t;

typedef union packed {
  logic [7:0] bytev;
  logic [7:0] other;
} pun_t;

typedef struct packed {
  logic [3:0] hi;
  logic [3:0] lo;
} pst_t;

typedef enum bit [1:0] {E0 = 2'd0, E1 = 2'd1} etwo_t;

module test_packed_union_size_and_implicit_conversion;
  uun_t u;
  pun_t p;
  pst_t s;
  etwo_t e;

  initial begin
    $display("logic_bits=%0d union_bits=%0d", $bits(logic), $bits(uun_t));
    $display("struct_bits=%0d packed_union_bits=%0d", $bits(pst_t), $bits(pun_t));
    p.bytev = 8'hA5;
    $display("u_b=%h u_o=%h", p.bytev, p.other);
    s = 8'h5A;
    $display("s_hi=%h s_lo=%h", s.hi, s.lo);
    $display("s_bits=%h", 8'(s));
    u.wordv = 16'h00C3;
    $display("u_low=%h", u.wordv[7:0]);
    e = etwo_t'(2'd3);
    $display("enum_coerced=%0d", e);
  end
endmodule
