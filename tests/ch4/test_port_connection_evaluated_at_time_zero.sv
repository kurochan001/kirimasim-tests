/*
:name: test_port_connection_evaluated_at_time_zero
:description: The implicit continuous assignments of input ports are evaluated at time zero, so a port connected to a constant expression or to a variable that keeps its declared initial value has that value without any change (IEEE 1800-2023 Section 4.9.1)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.9.1 4.9.6 23.3.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_port_connection_evaluated_at_time_zero.expected
*/
// IEEE 1800-2023 §4.9.1: a continuous assignment process is evaluated at time
// zero to propagate constant values, and so are the implicit continuous
// assignments of port connections (§4.9.6: an input port is a continuous
// assignment from the outside expression to the local net or variable).
// The child's net input ports a and b are connected to the constant 4'd9
// and to the constant expression K + 4'd1, and its variable input port c to
// the variable v, whose declaration gives it 5. None of these values ever
// changes, so only the time-zero evaluation gives the ports their values;
// without it a and b would stay z and c x. The child prints them at time 1.

module port_time_zero_child(input [3:0] a, input [3:0] b, input var logic [3:0] c);
  initial #1 $display("child: a=%0d b=%0d c=%0d", a, b, c);
endmodule

module test_port_connection_evaluated_at_time_zero;
  localparam logic [3:0] K = 4'd3;
  logic [3:0] v = 4'd5;

  port_time_zero_child u(.a(4'd9), .b(K + 4'd1), .c(v));
endmodule
