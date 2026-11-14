/*
:name: test_assignment_like_parens_mintypmax_conditional
:description: an assignment-like context reaches through parentheses, through each of the three expressions of a min:typ:max expression and into the second and third operands of the conditional operator, so assignment patterns and unpacked array concatenations there take the type of the target (IEEE 1800-2023 Section 10.8)
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.8 10.9 10.10
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assignment_like_parens_mintypmax_conditional.expected
*/
// IEEE 1800-2023 §10.8: when an expression is the right-hand value of an
// assignment-like context, so is the expression inside its parentheses, each
// of the colon-separated expressions of a min:typ:max expression, and the
// second and third operands of a conditional operator. An assignment
// pattern without a type there takes the type of the target (§10.9), and
// braces with an unpacked array target are an unpacked array concatenation
// (§10.10).
// pair_t is a packed structure of two 8-bit members. A pattern of two ints
// gives one int to each member; read as a vector concatenation it would be
// 64 bits cut to 16, and hi would be 0.
//   - Single and nested parentheses around a pattern.
//   - A min:typ:max expression whose three patterns all give hi = 3 and
//     lo = 4, and one whose three braces all give the two elements 1 and 2.
//     Which of the three is used is left to the tool (§11.11), so all three
//     give the same value; each of them needs the type of the target.
//   - For sel = 1 and then sel = 0, conditional operators whose second and
//     third operands are patterns or braces of different lengths, in a
//     blocking assignment, in a continuous assignment to a net and in the
//     argument of a function input; the result shows which operand was
//     taken and that it took the type of the target.
//   - A conditional operator nested in the third operand of another one.
// Icarus Verilog 13.0 cannot compile the pattern in the operand of the
// conditional operator of the continuous assignment ("sorry", then a failed
// assertion).

typedef struct packed {
  logic [7:0] hi;
  logic [7:0] lo;
} pair_t;

module test_assignment_like_parens_mintypmax_conditional;
  int three = 3, four = 4;
  bit sel = 1;
  pair_t p;
  logic [7:0] q [$];
  wire pair_t w;

  assign w = sel ? ('{three, four}) : '{four, three};

  function automatic int code(pair_t v);
    return v.hi * 100 + v.lo;
  endfunction

  initial begin
    p = ('{three, four});
    $display("parentheses: hi=%0d lo=%0d", p.hi, p.lo);
    p = ((('{four, three})));
    $display("nested parentheses: hi=%0d lo=%0d", p.hi, p.lo);
    p = ('{three, four} : '{four - 1, three + 1} : '{three * 1, four * 1});
    $display("min:typ:max patterns: hi=%0d lo=%0d", p.hi, p.lo);
    q = ({8'd1, 8'd2} : {8'd1, 8'd2} : {8'd1, 8'd2});
    $display("min:typ:max braces: size=%0d %0d %0d", q.size(), q[0], q[1]);
    for (int i = 1; i >= 0; i--) begin
      sel = i;
      p = sel ? '{three, four} : '{four, three};
      q = sel ? {8'd5, 8'd6} : {8'd7, 8'd8, 8'd9};
      #1;
      $display("sel=%0d: assignment hi=%0d lo=%0d, braces size=%0d first=%0d last=%0d", sel,
               p.hi, p.lo, q.size(), q[0], q[$]);
      $display("sel=%0d: continuous hi=%0d lo=%0d, argument %0d", sel, w.hi, w.lo,
               code(sel ? '{three, three} : ('{four, four})));
    end
    p = sel ? '{1, 2} : (sel ? '{3, 4} : '{5, 6});
    $display("nested conditional: hi=%0d lo=%0d", p.hi, p.lo);
  end
endmodule
