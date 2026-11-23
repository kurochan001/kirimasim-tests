/*
:name: test_function_port_directions_constant_and_runtime
:description: An input-only function supplies a parameter while procedural calls use output, inout and ref formals with the same function body
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4.3 13.4.1
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: constant_function_ports/port_directions.svh
:expected_stdout: @test_function_port_directions_constant_and_runtime.expected
*/
module test_function_port_directions_constant_and_runtime;
  `include "port_directions.svh"

  localparam int folded = port_input(40, 0);

  initial begin
    int slot, a, b, c;
    slot = 7;
    a = port_output(10, slot);
    b = port_inout(20, slot);
    c = port_ref(30, slot);
    $display("constant=%0d output=%0d inout=%0d ref=%0d", folded, a, b, c);
  end
endmodule
