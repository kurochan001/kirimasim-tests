/*
:name: test_gate_instance_array
:description: Arrays of gate instances share out vector bits by index, connect a scalar to every instance, and carry a drive strength (IEEE 1800-2023 Section 28.3.5)
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.3.5 28.3.6 28.3.2 21.2.1.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_gate_instance_array.expected
*/
// IEEE 1800-2023 §28.3.5: a range after the instance name makes an array of
// gates. §28.3.6: a vector as wide as the array gives each instance one bit,
// the rightmost bit going to the instance of the right-hand index, and a scalar
// is connected to every instance. §28.3.2: a drive strength after the gate type
// sets the strength of the outputs, for every instance of the array.

module test_gate_instance_array;
  logic [3:0] a = 4'b1100, b = 4'b1010;
  wire [3:0] y_and, y_scalar;
  wire [1:4] y_or;
  wire [1:0] y_weak;

  and g_and[3:0] (y_and, a, b);
  and g_scalar[3:0] (y_scalar, a, 1'b1);
  or  g_or[1:4] (y_or, a, b);
  buf (weak0, weak1) g_weak[1:0] (y_weak, 2'b10);
  assign (pull0, pull1) y_weak[0] = 1'b1;

  initial begin
    #1;
    $display("and: %b  scalar input: %b  or: %b", y_and, y_scalar, y_or);
    $display("weak buf alone: %v  weak buf vs pull1: %v", y_weak[1], y_weak[0]);
  end
endmodule
