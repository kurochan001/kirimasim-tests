/*
:name: test_vpi_variable_port_relations
:description: A variable that is the low connection of a port iterates that port with vpiPorts, a variable connected to ports of instances iterates them with vpiPortInst, and vpiLowConn and vpiHighConn of a port lead to the variables connected inside and outside the instance (IEEE 1800-2023 Section 37.17)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.17 37.14 23.2.2.3 23.3.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_variable_port_relations.c
:expected_stdout: @test_vpi_variable_port_relations.expected
*/
// IEEE 1800-2023 §37.17: variables have a one-to-many relation to ports by
// vpiPorts (the ports of their module whose low connection they are) and by
// vpiPortInst (the ports of instances whose high connection they are), and a
// port has the variables as vpiLowConn and vpiHighConn (37.14 details 3 and
// 4). In the submodule, a is an input variable port (var, 23.2.2.3), and y and
// n are output ports, variables by default. vpiPorts of u1.y gives port y of
// u1 (index 1), of u1.a port a (index 0), and of the module variable dst none,
// as the top module has no ports. src is connected to a of u1 and of u2, dst
// to y of u1 only, since y of u2 is left open; u1.y is no high connection, so
// vpiPortInst of src gives two ports, of dst one, of u1.y none. vpiLowConn of
// port y of u1 is the variable u1.y and of n u1.n; vpiHighConn of these ports
// is dst and cnt, and of y of u2, which has no connection, NULL (37.14 detail
// 10). Ports are listed as instance.port, sorted.

module test_vpi_variable_port_relations_sub (input var logic [3:0] a, output logic [3:0] y,
                                             output int n);
  assign y = a;
  always_comb n = a + 1;
endmodule

module test_vpi_variable_port_relations;
  logic [3:0] src = 4'h5;
  logic [3:0] dst;
  int cnt;

  test_vpi_variable_port_relations_sub u1 (.a(src), .y(dst), .n(cnt));
  test_vpi_variable_port_relations_sub u2 (.a(src), .y(), .n());

  initial #1 $vt_ports;
endmodule
