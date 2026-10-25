/*
:name: test_randomize_call_argument_lists_and_with_forms
:description: randomize calls as methods and in a scope, with attribute instances, without parentheses, with empty parentheses, a list of variables or null, and with an unrestricted constraint block, a restricted one after an identifier list of one or two names, and local:: names; each call has a single solution or a fixed check result (IEEE 1800-2023 Section 18.7)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.7 18.7.1 18.11 18.11.1 18.12 A.8.2 A.8.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_randomize_call_argument_lists_and_with_forms.expected
*/
// IEEE 1800-2023 A.8.2: a randomize call is randomize, attribute instances,
// optional parentheses holding nothing, a list of variable names or null,
// and an optional with, an optional parenthesized identifier list and a
// constraint block; it is a built-in method call or, with an optional std::,
// a scope randomize. §18.11: a list of names makes exactly those variables
// random and the others state variables; §18.11.1: null makes all of them
// state variables, so the call only returns 1 when the constraints hold and
// 0 otherwise. §18.7: in a constraint block without an identifier list,
// names resolve in the object first; with a list, only the listed names
// resolve in the object and the others in the scope of the call. §18.7.1:
// local::y always resolves in the scope of the call. §18.12: std::randomize
// and randomize make the listed variables random.
//
// The object o has rand x and y with 0 < x, y < 100; the module has its own
// x = 50 and y = 7. Each call returns 1 except the checker on x = 200:
//   o.randomize() with {x == 10; y == x + 1;}        x 10 y 11
//   o.randomize (* r *) () with {x == 3; y == 4;}    x 3 y 4
//   o.randomize (* r2 *) without parentheses: 1, with 0 < x < 100 (1)
//   o.y = 20; o.randomize(x) with {x == y + 1;}      x 21 y 20
//   o.randomize(x, y) with {x == 30; y == x + 2;}    x 30 y 32
//   o.x = 21; o.y = 20; o.randomize(null)            1, and after o.x = 200
//   o.randomize(null)                                0 with x still 200
//   o.randomize(x) with (x) {x == y;}                x 7 (y is the module y)
//   o.randomize(x) with (x, y) {x == y - 5;}         x 15 (y is o.y, 20)
//   o.randomize(x) with {x == local::y + 1;}         x 8
//   o.randomize(x) with (x) {x == local::x - 40;}    x 10
//   std::randomize(a, b) with {a + b == 10; a == 3;} a 3 b 7
//   randomize(a) with {a == b * 2;}                  a 14 (b stays 7)
//
// Icarus Verilog 13.0 does not support constraint declarations.

module test_randomize_call_argument_lists_and_with_forms;
  class rk;
    rand int x;
    rand int y;
    constraint c1 {x > 0; x < 100; y > 0; y < 100;}
  endclass

  int x = 50, y = 7;
  int a, b, ok, ok2;
  rk o;

  initial begin
    o = new;
    ok = o.randomize() with {x == 10; y == x + 1;};
    $display("unrestricted %0d %0d %0d", ok, o.x, o.y);
    ok = o.randomize (* r *) () with {x == 3; y == 4;};
    $display("attr %0d %0d %0d", ok, o.x, o.y);
    ok = o.randomize (* r2 *);
    $display("noparen %0d %0d", ok, o.x > 0 && o.x < 100 && o.y > 0 && o.y < 100);
    o.y = 20;
    ok = o.randomize(x) with {x == y + 1;};
    $display("list1 %0d %0d %0d", ok, o.x, o.y);
    ok = o.randomize(x, y) with {x == 30; y == x + 2;};
    $display("list2 %0d %0d %0d", ok, o.x, o.y);
    o.x = 21;
    o.y = 20;
    ok = o.randomize(null);
    o.x = 200;
    ok2 = o.randomize(null);
    $display("null %0d %0d %0d", ok, ok2, o.x);
    ok = o.randomize(x) with (x) {x == y;};
    $display("restricted1 %0d %0d", ok, o.x);
    ok = o.randomize(x) with (x, y) {x == y - 5;};
    $display("restricted2 %0d %0d", ok, o.x);
    ok = o.randomize(x) with {x == local::y + 1;};
    $display("local %0d %0d", ok, o.x);
    ok = o.randomize(x) with (x) {x == local::x - 40;};
    $display("restricted_local %0d %0d", ok, o.x);
    ok = std::randomize(a, b) with {a + b == 10; a == 3;};
    $display("scope %0d %0d %0d", ok, a, b);
    ok = randomize(a) with {a == b * 2;};
    $display("scope_nostd %0d %0d %0d", ok, a, b);
  end
endmodule
