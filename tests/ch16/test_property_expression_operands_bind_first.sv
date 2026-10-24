/*
:name: test_property_expression_operands_bind_first
:description: the expression operators of Table 11-2, down to the conditional operator and the logical implication and equivalence, bind tighter than every sequence and property operator, so a -> b iff c is (a -> b) iff c and a ? b : c or e is (a ? b : c) or e, and strong and weak take their operand in parentheses (IEEE 1800-2023 Section 16.12)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.12
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_property_expression_operands_bind_first.expected
*/
// IEEE 1800-2023 §16.12: all operators of Table 11-2 have higher precedence
// than the sequence and property operators of Table 16-3, and strong and
// weak always take their sequence in parentheses. The lowest expression
// operators are the conditional operator ?: and the logical implication ->
// and equivalence <-> (§11.4.7); each assertion below, written without
// parentheses, groups its expression operators first, and the expression is
// the Boolean operand of the property operator: (a -> b) iff c, (a <-> b)
// and c, (a ? b : c) or e, (a || b) implies c, (a == b) |-> c and (a & b) |->
// (c ~^ e).
// The eight ticks at 5, 15, ..., 75 take a, b, c through 000 to 111, with e
// high at the second, third, sixth and seventh. Each assertion writes P or
// F per tick, and the strings are printed at the end.
// Icarus Verilog 13.0 does not support these assertions; Verilator 5.052
// rejects or after a ?: operand and strong and weak (the other strings
// agree with the standard).

`timescale 1ns/1ns

module test_property_expression_operands_bind_first;
  logic clk = 0, a = 0, b = 0, c = 0, e = 0;
  string m[string];
  string order[] = '{"a -> b iff c", "a <-> b and c", "a ? b : c or e", "a || b implies c",
                      "a == b |-> c", "a & b |-> c ~^ e", "strong(a) or weak(b)"};

  function automatic void r(string name, string v);
    if (m.exists(name)) m[name] = {m[name], v};
    else m[name] = v;
  endfunction

  always #5 clk = ~clk;   // ticks at 5, 15, ..., 75

  p1: assert property (@(posedge clk) a -> b iff c)
    r("a -> b iff c", "P"); else r("a -> b iff c", "F");
  p2: assert property (@(posedge clk) a <-> b and c)
    r("a <-> b and c", "P"); else r("a <-> b and c", "F");
  p3: assert property (@(posedge clk) a ? b : c or e)
    r("a ? b : c or e", "P"); else r("a ? b : c or e", "F");
  p4: assert property (@(posedge clk) a || b implies c)
    r("a || b implies c", "P"); else r("a || b implies c", "F");
  p5: assert property (@(posedge clk) a == b |-> c)
    r("a == b |-> c", "P"); else r("a == b |-> c", "F");
  p6: assert property (@(posedge clk) a & b |-> c ~^ e)
    r("a & b |-> c ~^ e", "P"); else r("a & b |-> c ~^ e", "F");
  p7: assert property (@(posedge clk) strong(a) or weak(b))
    r("strong(a) or weak(b)", "P"); else r("strong(a) or weak(b)", "F");

  initial begin
    for (int k = 0; k < 8; k++) begin
      {a, b, c} = k[2:0];
      e = k inside {1, 2, 5, 6};
      #10;
    end
    foreach (order[i]) $display("%s: %s", order[i], m.exists(order[i]) ? m[order[i]] : "");
    $finish;
  end
endmodule
