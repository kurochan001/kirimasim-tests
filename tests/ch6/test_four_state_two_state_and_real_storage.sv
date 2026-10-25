/*
:name: test_four_state_two_state_and_real_storage
:description: Each bit of a logic vector, and of types built from logic, holds 0, 1, x or z on its own, while a 2-state bit holds only 0 or 1 and a real holds a real number, with x and z bits converted to 0 (IEEE 1800-2023 Section 6.3.1)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.3.1 6.11.2 6.12.1 6.8
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_four_state_two_state_and_real_storage.expected
*/
// IEEE 1800-2023 §6.3.1: logic is the basic 4-state type; it declares
// objects and builds other types, and every bit of a 4-state vector can be
// set to 0, 1, x or z on its own. A 2-state type stores only 0 or 1 in each
// bit; §6.11.2: x and z bits become 0 when a 4-state value is converted to
// it. The real types are outside the 4-state set: §6.12.1 converts x and z
// bits to 0 when a value is assigned to a real, and §6.8 gives a real the
// initial value 0.0, where a logic variable starts as x.
// Line "bits" sets the four bits of a vector one by one and then changes one
// bit, which leaves the others as they were. Line "built" stores x and z in
// a typedef of logic, a packed structure of logic members and an unpacked
// array of logic. Line "two-state" assigns values with x and z to bit, int
// and byte variables. Line "real" prints an unassigned real and logic, a
// real given 4'b1x01, and a real holding a fraction.

module test_four_state_two_state_and_real_storage;
  typedef logic [3:0] nibble_t;
  typedef struct packed {
    logic flag;
    logic [2:0] code;
  } rec_t;

  logic [3:0] v;
  nibble_t n;
  rec_t r;
  logic m[0:1];
  bit [3:0] b;
  int i;
  byte by;
  real re, re_unset;
  logic lg_unset;

  initial begin
    v[0] = 1'b1;
    v[1] = 1'bx;
    v[2] = 1'bz;
    v[3] = 1'b0;
    $display("bits: %b", v);
    v[1] = 1'b0;
    $display("bits after v[1]=0: %b", v);
    n = 4'bz1x0;
    r.flag = 1'bx;
    r.code = 3'b1z0;
    m[0] = 1'bz;
    m[1] = 1'bx;
    $display("built: %b %b %b%b", n, r, m[0], m[1]);
    b = 4'b1x0z;
    i = 32'hxxxx_00zf;
    by = 8'bzzxx_1101;
    $display("two-state: %b %h %b", b, i, by);
    re = 4'b1x01;
    $display("real: unset=%0.1f logic_unset=%b from_xz=%0.1f", re_unset, lg_unset, re);
    re = 2.75;
    $display("real fraction: %0.2f", re);
  end
endmodule
