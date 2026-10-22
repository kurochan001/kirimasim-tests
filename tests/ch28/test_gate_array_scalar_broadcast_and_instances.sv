/*
:name: test_gate_array_scalar_broadcast_and_instances
:description: A gate instance array broadcasts a scalar input while mapping vector terminals bit by bit (IEEE 1800-2023 Section 28.3.1)
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.3.1 28.3.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_gate_array_scalar_broadcast_and_instances.expected
*/
// IEEE 1800-2023 28.3.1 28.3.2: One declaration contains two named instances
// and an array applies each vector bit against one shared enable.

module test_gate_array_scalar_broadcast_and_instances;
  logic [3:0] data = 4'b1010;
  logic enable = 0;
  wire [3:0] result;
  wire a, b;
  and gates[3:0](result, data, enable);
  buf first(a, 1'b1), second(b, 1'b0);
  initial begin
    #1 $display("disabled=%b scalar=%b,%b", result, a, b);
    enable = 1;
    #1 $display("enabled=%b", result);
  end
endmodule
