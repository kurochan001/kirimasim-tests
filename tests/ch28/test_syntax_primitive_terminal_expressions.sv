/*
:name: test_syntax_primitive_terminal_expressions
:description: input, enable, n-control and p-control terminals of primitive instances are expressions, and output and bidirectional terminals are selects of vector nets (IEEE 1800-2023 Section 28.3.6)
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.3.6 28.4 28.6 28.8 28.9 A.3.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_syntax_primitive_terminal_expressions.expected
*/
// IEEE 1800-2023 A.3.3, §28.3.6: the input, enable, n-control and p-control
// terminals of a gate or switch are expressions, and the output and
// bidirectional terminals are net lvalues. Here the inputs of an and gate
// are a & b and ~c, a bufif1 has the data input d ^ a and the enable
// e1 | e2, a cmos has the controls n1 & n2 and ~p, and a tranif1 has the
// control e1 & e2; the outputs are a bit-select and a part-select of the
// vector net w, and the tran and tranif1 connect bit-selects of bus.
//
// Three sets of inputs are applied. Each output is the gate function of the
// values of the expressions (28.4, 28.6, 28.9: cmos conducts when its
// n-control is 1 or its p-control is 0), and the right bits of w and bus
// change, so an expression evaluated wrongly or a select connected to the
// wrong bit changes a line.

module test_syntax_primitive_terminal_expressions;
  reg a, b, c, d, e1, e2, n1, n2, p;
  wire [3:0] w;
  wire [3:0] bus;

  assign bus[0] = a, bus[1] = b;

  and     g1 (w[0], a & b, ~c);
  bufif1  g2 (w[1], d ^ a, e1 | e2);
  cmos    g3 (w[2], d, n1 & n2, ~p);
  nand    g4 (w[3:3], a, b);
  tran    g5 (bus[0], bus[3]);
  tranif1 g6 (bus[1], bus[2], e1 & e2);

  task show;
    $display("w=%b bus[3]=%b bus[2]=%b", w, bus[3], bus[2]);
  endtask

  initial begin
    a = 1; b = 1; c = 0; d = 0; e1 = 0; e2 = 1; n1 = 1; n2 = 0; p = 0;
    #1 show;
    a = 0; d = 1; e1 = 1; n2 = 1;
    #1 show;
    a = 1; b = 0; c = 1; e1 = 0; e2 = 0; n1 = 0; p = 1;
    #1 show;
  end
endmodule
