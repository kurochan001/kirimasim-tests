/*
:name: test_n_input_n_output_gate_categories
:description: or, nor and xnor are n-input gates whose first terminal is the output and all others inputs, and not is an n-output gate whose last terminal is the input (IEEE 1800-2023 Section 28.3.1)
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.3.1 28.4 28.5
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_n_input_n_output_gate_categories.expected
*/
// IEEE 1800-2023 §28.3.1, Table 28-1: and, nand, nor, or, xnor and xor are
// the n-input gates, buf and not the n-output gates. §28.4: an n-input gate
// has one output, its first terminal, and one or more inputs, all the other
// terminals. §28.5: an n-output gate has one input, its last terminal, and
// one or more outputs, all the terminals before it.
// Two-, three- and four-input or, nor and xnor gates and a three-output not
// gate are driven with input patterns in which a single input is 1, so the
// output depends on which terminals are taken as inputs. Every gate output
// is a net of its own. xnor of several inputs is the inverse of their
// exclusive or.

module test_n_input_n_output_gate_categories;
  logic a, b, c, d;
  wire o2, o4, n3, x3, x4, q1, q2, q3;

  or   (o2, a, b);
  or   (o4, a, b, c, d);
  nor  (n3, a, b, c);
  xnor (x3, a, b, c);
  xnor (x4, a, b, c, d);
  not  (q1, q2, q3, d);

  initial begin
    for (int i = 0; i < 5; i++) begin
      {a, b, c, d} = (i == 0) ? 4'b0000 : 4'b1 << (i - 1);
      #1 $display("abcd=%b%b%b%b: or2=%b or4=%b nor3=%b xnor3=%b xnor4=%b not=%b%b%b",
                  a, b, c, d, o2, o4, n3, x3, x4, q1, q2, q3);
    end
  end
endmodule
