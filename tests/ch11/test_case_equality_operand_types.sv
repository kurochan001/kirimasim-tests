/*
:name: test_case_equality_operand_types
:description: === and !== take operands of any type except real and shortreal, as the rules of each type allow: 4-state and 2-state integral values, signed and unsigned ones, enums, packed structures, class handles, chandles, events and unpacked aggregates (IEEE 1800-2023 Section 11.3)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.3 11.4.5
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_case_equality_operand_types.expected
*/
// IEEE 1800-2023 §11.3, Table 11-1: the case equality operators === and !==
// accept operands of any data type except real and shortreal, subject to the
// rules for each type. §11.4.5: they compare bit for bit, x and z bits
// included, and always give a known 1'b1 or 1'b0; with an unsigned operand
// the shorter one is zero-extended, with two signed operands sign-extended;
// they also compare class handles, chandles or null. §15.5.5.3 allows them
// for events and null, and §11.2.2 lets equality operators compare unpacked
// aggregates of equivalent type.
// Each line compares a pair that is equal and a pair that differs, so a tool
// that compared only one kind of operand correctly would print another
// value. The 4-state line also shows that == gives x for the same operands.
// The signed byte -1 is sign-extended against the int -1 and equal to it, and
// the unsigned 8'hff is zero-extended and differs from it. The unpacked
// structures differ only in an x against a z bit, and the unpacked arrays
// only in an x against a 0 bit.
// Icarus Verilog 13.0 supports neither unpacked structures nor chandle
// variables, and the 5.054 release of Verilator reports the assignment of one
// event to another as unsupported.

class base_c;
  int k;
endclass

module test_case_equality_operand_types;
  typedef enum logic [1:0] {RED, GREEN, BLUE} color_t;
  typedef struct packed {
    logic [3:0] hi;
    bit [3:0] lo;
  } pk_t;
  typedef struct {
    int a;
    logic [1:0] b;
  } rec_t;
  typedef logic [3:0] quad_t [2];

  logic [3:0] l1 = 4'b10xz, l2 = 4'b10xz, l3 = 4'b10x0;
  bit [3:0] b1 = 4'b1010, b2 = 4'b1010, b3 = 4'b1011;
  int si = -1;
  byte sb = -1;
  logic [7:0] u8 = 8'hff;
  color_t e1 = GREEN, e2 = GREEN, e3 = BLUE;
  pk_t p1 = {4'b1x00, 4'd5}, p2 = {4'b1x00, 4'd5}, p3 = {4'b1z00, 4'd5};
  base_c h1, h2, h3;
  chandle ch1, ch2;
  event ev1, ev2, ev3;
  rec_t r1 = '{a: 1, b: 2'bx1}, r2 = '{a: 1, b: 2'bx1}, r3 = '{a: 1, b: 2'bz1};
  quad_t q1 = '{4'b000x, 4'b1111}, q2 = '{4'b000x, 4'b1111}, q3 = '{4'b0000, 4'b1111};

  initial begin
    h1 = new;
    h2 = h1;
    h3 = new;
    ev2 = ev1;
    $display("4-state: %b %b %b %b", l1 === l2, l1 !== l2, l1 === l3, l1 == l2);
    $display("2-state: %b %b", b1 === b2, b1 !== b3);
    $display("signed and unsigned: %b %b", si === sb, si === u8);
    $display("enum: %b %b", e1 === e2, e1 !== e3);
    $display("packed struct: %b %b", p1 === p2, p1 === p3);
    $display("class: %b %b %b", h1 === h2, h1 === h3, h3 !== null);
    $display("chandle: %b %b", ch1 === ch2, ch1 !== null);
    $display("event: %b %b %b", ev1 === ev2, ev1 === ev3, ev3 !== null);
    $display("unpacked: %b %b %b %b", r1 === r2, r1 === r3, q1 === q2, q1 !== q3);
  end
endmodule
