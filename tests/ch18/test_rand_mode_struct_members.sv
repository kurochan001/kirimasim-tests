/*
:name: test_rand_mode_struct_members
:description: rand_mode() on an unpacked structure changes one member when the member is named and every member when it is omitted (IEEE 1800-2023 Section 18.8)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.8 18.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_rand_mode_struct_members.expected
*/
// IEEE 1800-2023 §18.8: for an unpacked structure, rand_mode() can name one
// member, which is then the only one changed, and without the member it
// changes all the members. The structure p is declared rand and its members a
// and b are declared rand in its type (18.4), and c_p asks p.b == p.a + 5.
// With p.a off and set to 7, p.a is a state variable and p.b becomes 12, and
// the getters show a off and b on. With p off as a whole and p.b set to 0,
// both are state variables, 0 == 7 + 5 is false and randomize() fails,
// keeping the values. With p on again, both are random: p.a == 20 inline
// makes p.b 25.
// Icarus Verilog 13.0 does not compile classes with constraints, and Verilator
// 5.052 does not support rand_mode() on a member of an unpacked structure.

typedef struct {
  rand bit [7:0] a;
  rand bit [7:0] b;
} rms_pair_t;

class rms_obj;
  rand rms_pair_t p;
  constraint c_p { p.b == p.a + 8'd5; }
endclass

module test_rand_mode_struct_members;
  rms_obj o;
  int ok;

  initial begin
    o = new;
    o.p.a.rand_mode(0);
    o.p.a = 8'd7;
    ok = o.randomize();
    $display("p.a off: ok=%0d a=%0d b=%0d modes=%0d%0d", ok, o.p.a, o.p.b,
             o.p.a.rand_mode(), o.p.b.rand_mode());
    o.p.rand_mode(0);
    o.p.b = 8'd0;
    ok = o.randomize();
    $display("p off: ok=%0d a=%0d b=%0d modes=%0d%0d", ok, o.p.a, o.p.b,
             o.p.a.rand_mode(), o.p.b.rand_mode());
    o.p.rand_mode(1);
    ok = o.randomize() with { p.a == 8'd20; };
    $display("p on again: ok=%0d a=%0d b=%0d modes=%0d%0d", ok, o.p.a, o.p.b,
             o.p.a.rand_mode(), o.p.b.rand_mode());
  end
endmodule
