/*
:name: test_checker_dollar_actual_unbounded_range
:description: the terminal $ can be the actual argument of an untyped checker formal, passed in the instance or taken from the default, and the formal then works as an unbounded upper bound of ##[1:n] directly and when passed on to a sequence, a property and a nested checker instance (IEEE 1800-2023 Section 17.3)
:tags: ch17
:type: simulation
:lrm: 1800-2023 17.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_checker_dollar_actual_unbounded_range.expected
*/
// IEEE 1800-2023 §17.3: the terminal $ may be an actual argument of a checker
// instance, passed in its list of arguments or declared as the default actual
// argument; the corresponding formal is untyped, and it may be referenced as
// the upper bound of a cycle delay range or as an actual argument of a
// sequence, property or checker instance. After the rewriting of the checker
// (F.4.2), s ##[1:n] a with n bound to $ is s ##[1:$] a, which can match any
// number of cycles after s.
// unb_chk uses its formal n in four ways: as the bound of ##[1:n] in c_direct,
// and as the actual for the bound of the sequence s_rng, the property p_rng
// and the nested checker unb_inner. Each cover prints the time when it
// succeeds. The clock rises at 10 * k + 5 (tick k). u1 passes $ and u2 takes
// the default $; u3 passes 5 and sees the same inputs as u1.
// For u1, s1 is high at tick 1 and a1, b1, c1 and d1 at ticks 21, 22, 23 and
// 24, so its covers succeed 20 to 23 cycles after s1, at 215, 225, 235 and
// 245. For u2, s2 is high at tick 2 and a2 to d2 at ticks 31 to 34, 29 to 32
// cycles later: 315, 325, 335 and 345. With the bound 5, the covers of u3 can
// succeed only up to tick 6, when all of a1 to d1 are low, so u3 prints
// nothing. Each cover succeeds once, at a time of its own, so the order of
// the lines is fixed.
// Icarus Verilog 13.0 does not support checkers, and the 5.054 release
// of Verilator does not support the default value of a checker port.

`timescale 1ns/1ns

checker unb_chk(event clk, int id, logic s, logic a, logic b, logic c, logic d,
                untyped n = $);
  sequence s_rng(x, y, m);
    x ##[1:m] y;
  endsequence

  property p_rng(x, y, m);
    x ##[1:m] y;
  endproperty

  checker unb_inner(event ck, int k, logic x, logic y, untyped m);
    c_nested: cover property (@ck x ##[1:m] y) $display("%0t u%0d checker", $time, k);
  endchecker : unb_inner

  c_direct: cover property (@clk s ##[1:n] a) $display("%0t u%0d direct", $time, id);
  c_seq: cover property (@clk s_rng(s, b, n)) $display("%0t u%0d sequence", $time, id);
  c_prop: cover property (@clk p_rng(s, c, n)) $display("%0t u%0d property", $time, id);
  unb_inner u_in(clk, id, s, d, n);
endchecker : unb_chk

module test_checker_dollar_actual_unbounded_range;
  logic clk = 1'b0;
  logic s1 = 1'b0, a1 = 1'b0, b1 = 1'b0, c1 = 1'b0, d1 = 1'b0;
  logic s2 = 1'b0, a2 = 1'b0, b2 = 1'b0, c2 = 1'b0, d2 = 1'b0;

  always #5 clk = ~clk;

  unb_chk u1(posedge clk, 1, s1, a1, b1, c1, d1, $);
  unb_chk u2(.clk(posedge clk), .id(2), .s(s2), .a(a2), .b(b2), .c(c2), .d(d2));
  unb_chk u3(posedge clk, 3, s1, a1, b1, c1, d1, 5);

  initial begin
    #10 s1 = 1'b1;               // tick 1
    #10 s1 = 1'b0; s2 = 1'b1;    // tick 2
    #10 s2 = 1'b0;
    #180 a1 = 1'b1;              // tick 21
    #10 a1 = 1'b0; b1 = 1'b1;    // tick 22
    #10 b1 = 1'b0; c1 = 1'b1;    // tick 23
    #10 c1 = 1'b0; d1 = 1'b1;    // tick 24
    #10 d1 = 1'b0;
    #60 a2 = 1'b1;               // tick 31
    #10 a2 = 1'b0; b2 = 1'b1;    // tick 32
    #10 b2 = 1'b0; c2 = 1'b1;    // tick 33
    #10 c2 = 1'b0; d2 = 1'b1;    // tick 34
    #10 d2 = 1'b0;
    #20 $finish;
  end
endmodule
