/*
:name: test_class_value_parameters_through_handles
:description: A value parameter and a local value parameter of a class are read by qualifying their names with an object handle, and give the values of the specialization of that handle (IEEE 1800-2023 Section 8.5)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.5
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_value_parameters_through_handles.expected
*/
// IEEE 1800-2023 §8.5: the parameter data of an object can be read by
// qualifying the name of a class value parameter or local value parameter
// with an instance name, like a class property. gauge_c has the value
// parameter WIDTH and the local value parameter TOP, which depends on it.
// g3, g4 and g6 are handles of three specializations: gauge_c#(3), the
// default gauge_c with WIDTH 4, and gauge_c#(.WIDTH(6)). Each handle gives
// the WIDTH and TOP of its own specialization: 3 and 7, 4 and 15, 6 and 63.
// The last line uses g3.TOP and g6.WIDTH in an expression with the property
// g4.reading: 7 + 6 * 2 = 19. An implementation that read the defaults, or
// one specialization for every handle, would print other numbers.
// Icarus Verilog 13.0 does not support parameterized classes.

class gauge_c #(int WIDTH = 4);
  localparam int TOP = (1 << WIDTH) - 1;
  int reading;
  function new(int r);
    reading = r;
  endfunction
endclass

module test_class_value_parameters_through_handles;
  gauge_c #(3) g3;
  gauge_c g4;
  gauge_c #(.WIDTH(6)) g6;
  int sum;

  initial begin
    g3 = new(1);
    g4 = new(2);
    g6 = new(3);
    $display("g3: WIDTH=%0d TOP=%0d", g3.WIDTH, g3.TOP);
    $display("g4: WIDTH=%0d TOP=%0d", g4.WIDTH, g4.TOP);
    $display("g6: WIDTH=%0d TOP=%0d", g6.WIDTH, g6.TOP);
    sum = g3.TOP + g6.WIDTH * g4.reading;
    $display("sum=%0d", sum);
  end
endmodule
