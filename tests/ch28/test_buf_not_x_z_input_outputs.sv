/*
:name: test_buf_not_x_z_input_outputs
:description: buf and not gates with two outputs drive x on every output when their input is x or z (IEEE 1800-2023 Section 28.5)
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_buf_not_x_z_input_outputs.expected
*/
// IEEE 1800-2023 §28.5, Table 28-4: buf copies a known input to its outputs
// and not inverts it, but an unknown input, x or z, gives x on the outputs of
// both gates. A buf gate is therefore not a plain connection: a z input does
// not pass through as z. The rule applies to each output of a gate that has
// several, all of which come before the single input in the terminal list.
// The test drives the input of a two-output buf and a two-output not, whose
// outputs are nets, with 0 and 1 as controls and then x and z, and prints
// every output 1 time unit after each change.

module test_buf_not_x_z_input_outputs;
  logic d;
  wire b1, b2, n1, n2;
  logic v[4] = '{1'b0, 1'b1, 1'bx, 1'bz};

  buf gb (b1, b2, d);
  not gn (n1, n2, d);

  initial begin
    for (int i = 0; i < 4; i++) begin
      d = v[i];
      #1 $display("d=%b buf=%b%b not=%b%b", d, b1, b2, n1, n2);
    end
  end
endmodule
