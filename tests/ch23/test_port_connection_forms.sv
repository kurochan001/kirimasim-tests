/*
:name: test_port_connection_forms
:description: Module ports connected by position, by .name, by .* and by explicit name, with an explicit connection mixed into .* (IEEE 1800-2023 Section 23.3.2)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.3.2 23.3.2.1 23.3.2.2 23.3.2.3 23.3.2.4
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_port_connection_forms.expected
*/
// IEEE 1800-2023 §23.3.2: ports can be connected by their order (23.3.2.1), by
// explicit names (23.3.2.2), by .name, which connects the port to the signal of
// the same name (23.3.2.3), or by .*, which does that for every port
// (23.3.2.4). A named connection can be mixed with .* to connect one port to
// something else. All forms connect the same ports here, so they give the same
// sums.

module port_forms_adder(input logic [7:0] a, input logic [7:0] b, input logic cin,
                        output logic [8:0] sum);
  assign sum = a + b + cin;
endmodule

module test_port_connection_forms;
  logic [7:0] a = 8'd10, b = 8'd20;
  logic cin = 1'b1;
  logic [8:0] sum;
  logic [8:0] s_order, s_named, s_dot, s_mixed;

  port_forms_adder u_order (a, b, cin, s_order);
  port_forms_adder u_named (.sum(s_named), .cin(cin), .b(b), .a(a));
  port_forms_adder u_dot   (.a, .b, .cin, .sum(s_dot));
  port_forms_adder u_star  (.*);
  port_forms_adder u_mixed (.*, .b(8'd100), .sum(s_mixed));

  initial #1 $display("order=%0d named=%0d dot=%0d star=%0d mixed=%0d",
                      s_order, s_named, s_dot, sum, s_mixed);
endmodule
