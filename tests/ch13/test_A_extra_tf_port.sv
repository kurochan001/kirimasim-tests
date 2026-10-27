/*
:name: test_A_extra_tf_port
:description: A tf port item takes attribute instances, an optional direction and var, a data or implicit type, a name with optional dimensions and a default expression, and the implicit type of a following port is the one-bit logic type (IEEE 1800-2023 Sections 13.3 and 13.4, A.2.7)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.3 13.4 A.2.7
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_A_extra_tf_port.expected
*/
// IEEE 1800-2023 A.2.7, tf_port_item: attribute instances, the optional
// tf_port_direction, the optional var, data_type_or_implicit, then the port
// identifier with its variable dimensions and an optional default expression.
// Clause 28 of A.10 allows the port identifier to be omitted only in a
// prototype, so every port here is named.
//
// tp has the attributed var port a with a packed dimension and default 3 and
// the int port b with default 1. The function f declares its ports with only
// the input direction, so a and b take the implicit data type, which is the
// one-bit logic type; f(1, 0) is 1. The call tp(4, 5) gives 9.
//
// Icarus Verilog 13.0 rejects an attribute instance on a tf port item, so
// the expected output is recorded with the 5.052 release of Verilator.

module test_A_extra_tf_port;
  int o;

  task automatic tp((* keep *) input var logic [3:0] a = 4'h3,
                    input int b = 1, output int o);
    o = a + b;
  endtask

  function automatic int f(input a, b);
    return a + b;
  endfunction

  initial begin
    tp(4, 5, o);
    $display("%0d %0d", o, f(1, 0));
  end
endmodule
