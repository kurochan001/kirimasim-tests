/*
:name: test_syntax_blocking_assignment_new_and_timed_forms
:description: every form of the blocking assignment syntax, a timed assignment, a dynamic array new, a class new on a plain, selected, this, super, class-scoped or package-scoped handle, an operator assignment and an increment or decrement, assigns the value its form gives (IEEE 1800-2023 Section 10.4.1)
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.4.1
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_syntax_blocking_assignment_new_and_timed_forms.expected
*/
// IEEE 1800-2023 §10.4.1, Syntax 10-2: a blocking assignment is one of
// - a variable lvalue, =, an intra-assignment delay or event control and an
//   expression: the expression is evaluated at once and the variable is
//   assigned when the control has passed (§9.4.5);
// - a variable lvalue without a range, = and a dynamic array new (§7.5.1);
// - a handle, optionally after this., super., a class scope or a package
//   scope and with a select, = and a class new: new with or without
//   arguments, a class scope before new, which constructs that class
//   (§8.8), or new followed by a handle, which copies its object (§8.12);
// - an operator assignment with = or a compound operator (§11.4.1);
// - an increment or decrement expression (§11.4.2).
//
// a = #2 b reads b, 2, at time 0, and a gets it at time 2, although b has
// become 7 at time 1. e = @(ev) c reads c, 3, at time 2 and e gets it when
// ev is triggered at time 3, after c has become 9. d = new[3] makes three
// elements, and d = new[5](d) five, the first three copied and the others 0.
// box_c::new has a default argument of 1; wide_box_c::new(2) constructs a
// wide_box_c, whose constructor gives 10 times its argument, and new h makes a
// separate copy, which keeps 20 when h.v becomes 21. fill and refill assign
// new objects through this., the class scope holder_c::, the select
// slots[1] and super.; bf_pkg::pkg_box is assigned through the package
// scope. The compound operators are applied in turn to x and to the signed
// byte s, and i is incremented and decremented with both forms.
// Icarus Verilog 13.0 does not parse a handle with a class scope or a
// package scope before it, on either side of an assignment.

`timescale 1ns/1ns

package bf_pkg;
  class box_c;
    int v;
    function new(int v0 = 1);
      v = v0;
    endfunction
  endclass
  box_c pkg_box;
endpackage

module test_syntax_blocking_assignment_new_and_timed_forms;
  import bf_pkg::box_c;

  class wide_box_c extends box_c;
    function new(int v0 = 1);
      super.new(10 * v0);
    endfunction
  endclass

  class holder_c;
    static box_c shared;
    box_c own;
    box_c slots[2];
    function void fill();
      this.own = new(11);
      holder_c::shared = new(12);
      slots[1] = new(13);
    endfunction
  endclass

  class sub_holder_c extends holder_c;
    function void refill();
      super.own = new(14);
    endfunction
  endclass

  int a, b, c, e, x, i;
  logic signed [7:0] s;
  int d[];
  event ev;
  box_c h, h2;
  sub_holder_c sh;

  initial begin
    a = 0;
    b = 2;
    fork
      #1 b = 7;
    join_none
    a = #2 b;
    $display("delay: t=%0d a=%0d b=%0d", $time, a, b);
    c = 3;
    fork
      begin
        #1 c = 9;
        -> ev;
      end
    join_none
    e = @(ev) c;
    $display("event: t=%0d e=%0d c=%0d", $time, e, c);

    d = new[3];
    d[0] = 4;
    d[1] = 5;
    d[2] = 6;
    d = new[5](d);
    $display("dynamic new: size=%0d d=%0d %0d %0d %0d %0d",
             d.size(), d[0], d[1], d[2], d[3], d[4]);

    h = new;
    $display("new: %0d", h.v);
    h = new(5);
    $display("new(5): %0d", h.v);
    h = wide_box_c::new(2);
    $display("typed new: %0d", h.v);
    h2 = new h;
    h.v = 21;
    $display("copy: %0d %0d", h2.v, h.v);
    sh = new;
    sh.fill();
    bf_pkg::pkg_box = new(15);
    $display("this=%0d class scope=%0d select=%0d package scope=%0d",
             sh.own.v, holder_c::shared.v, sh.slots[1].v, bf_pkg::pkg_box.v);
    sh.refill();
    $display("super=%0d", sh.own.v);

    x = 100;
    x += 5;
    x -= 3;
    x *= 2;
    $display("+= -= *=: %0d", x);
    x /= 4;
    x %= 7;
    $display("/= %%=: %0d", x);
    x |= 8;
    x &= 12;
    x ^= 3;
    $display("|= &= ^=: %0d", x);
    x <<= 2;
    x >>= 1;
    $display("<<= >>=: %0d", x);
    s = -16;
    s <<<= 1;
    $display("<<<=: %0d", s);
    s >>>= 3;
    $display(">>>=: %0d", s);

    i = 5;
    i++;
    ++i;
    $display("++: %0d", i);
    i--;
    --i;
    --i;
    $display("--: %0d", i);
  end
endmodule
