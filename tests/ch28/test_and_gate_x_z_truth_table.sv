/*
:name: test_and_gate_x_z_truth_table
:description: a two-input and gate gives the Table 28-3 output for each of the sixteen pairs of 0, 1, x and z inputs (IEEE 1800-2023 Section 28.4)
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_and_gate_x_z_truth_table.expected
*/
// IEEE 1800-2023 §28.4, Table 28-3: the output of a two-input and gate for
// each pair of input values 0, 1, x and z.
// A 0 on either input makes the output 0 whatever the other input is;
// otherwise an x or z on an input makes the output x, and two 1 inputs
// give 1. A z input acts like x.
// The test drives the two inputs of one and gate, whose output is a net,
// with all sixteen pairs, the known pairs serving as controls, and prints
// the inputs and the output 1 time unit after each change, when no other
// event is pending.

module test_and_gate_x_z_truth_table;
  logic a, b;
  wire y;
  logic v[4] = '{1'b0, 1'b1, 1'bx, 1'bz};

  and g1 (y, a, b);

  initial begin
    for (int i = 0; i < 4; i++)
      for (int j = 0; j < 4; j++) begin
        a = v[i];
        b = v[j];
        #1 $display("and(%b, %b) = %b", a, b, y);
      end
  end
endmodule
