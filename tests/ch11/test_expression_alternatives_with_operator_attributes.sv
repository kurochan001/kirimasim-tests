/*
:name: test_expression_alternatives_with_operator_attributes
:description: An expression is a primary, a unary operator with attribute instances before its primary, an increment or decrement with attributes between operator and operand, a parenthesized operator assignment, a binary operator with attributes after it, a conditional operator with attributes after the question mark, or an inside expression; the attributes do not change the values (IEEE 1800-2023 Section 11.3.6)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.3.6 11.4.2 11.4.13 11.4.11 5.12 A.8.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_expression_alternatives_with_operator_attributes.expected
*/
// IEEE 1800-2023 A.8.3: an expression is a primary; a unary operator, any
// number of attribute instances and a primary; an increment or decrement
// expression, which is the operator, attributes and a variable, or the
// variable, attributes and the operator; an operator assignment in
// parentheses; two expressions around a binary operator that may be followed
// by attributes; a conditional expression, whose question mark may be
// followed by attributes; or an inside expression. §5.12: an attribute
// instance can follow an operator and only gives properties to tools, so each
// value below is the value of the operator alone (§11.4.2, §11.3.6, §11.4.11,
// §11.4.13):
//   - (* neg, w = 3 *) x with x 4 is -4, and ~ with two attribute instances
//     gives -5;
//   ++ (* pre *) i with i 3 gives 4 and leaves 4; i (* post *) (* twice *) --
//     then gives the old 4 and leaves 3;
//   (x += 3) * 2 sets x to 7 and is 14; (y = 9) + (i <<= 2) sets y to 9 and i
//     to 12 and is 21;
//   x + (* mark *) 2 is 9, and x * (* a *) (* b = 1 *) 3 - (* c *) 1 is 20;
//   the conditional gives 10 when c is 1 and 20 when c is 0;
//   20 is inside the unpacked array {10, 20, 30} and 25 is not; x (7) is
//   inside {1, [6:8]} and not inside {2, [3:5]}.
//
// Icarus Verilog 13.0 rejects the attribute instances after the operators of
// the increment and decrement expressions and of the conditional operator as
// syntax errors, and does not support inside expressions.

module test_expression_alternatives_with_operator_attributes;
  int x, y, i, r1, r2;
  int set [3] = '{10, 20, 30};
  bit c;

  initial begin
    x = 4;
    y = x;
    $display("primary %0d %0d", x, y);
    r1 = - (* neg, w = 3 *) x;
    r2 = ~ (* inv *) (* again *) x;
    $display("unary %0d %0d", r1, r2);
    i = 3;
    r1 = ++ (* pre *) i;
    $display("pre %0d %0d", r1, i);
    r2 = i (* post *) (* twice *) --;
    $display("post %0d %0d", r2, i);
    r1 = (x += 3) * 2;
    r2 = (y = 9) + (i <<= 2);
    $display("assign %0d %0d %0d %0d %0d", r1, x, r2, y, i);
    r1 = x + (* mark *) 2;
    r2 = x * (* a *) (* b = 1 *) 3 - (* c *) 1;
    $display("binary %0d %0d", r1, r2);
    c = 1;
    r1 = c ? (* pick *) 10 : 20;
    c = 0;
    r2 = c ? (* pick, n = 2 *) 10 : 20;
    $display("cond %0d %0d", r1, r2);
    $display("inside %0d %0d %0d %0d", 20 inside {set}, 25 inside {set}, x inside {1, [6:8]},
             x inside {2, [3:5]});
  end
endmodule
