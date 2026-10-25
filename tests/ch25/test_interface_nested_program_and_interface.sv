/*
:name: test_interface_nested_program_and_interface
:description: An interface item can be a nested interface declaration, which the interface instantiates explicitly, or a nested program declaration, which is instantiated implicitly once and sees the variables of the interface (IEEE 1800-2023 Section 25.3)
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.3 24.3 A.1.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_interface_nested_program_and_interface.expected
*/
// IEEE 1800-2023 A.1.6: a non_port_interface_item can be an interface
// declaration or a program declaration. §25.3: an interface can contain
// smaller interfaces, and an interface is never instantiated implicitly, so
// np_if instantiates its nested interface np_inner as u_inner. §24.3: a
// program can be nested in an interface, where it shares the variables of
// that scope, and a nested program without ports is instantiated once
// implicitly. np_prog reads data of np_if and k of u_inner at time 2; the end
// of its only initial procedure ends the simulation (24.3), after the line
// that the top module prints at time 1.
// Icarus Verilog 13.0 rejects the instance of the nested interface ("Module
// instantiations are not allowed in interfaces"), and the 5.052 release
// of Verilator does not support interface declarations within interfaces.

interface np_if;
  int data = 5;

  interface np_inner;
    int k = 42;
  endinterface
  np_inner u_inner();

  program np_prog;
    initial #2 $display("prog data=%0d k=%0d", data, u_inner.k);
  endprogram
endinterface

module test_interface_nested_program_and_interface;
  np_if u_if();

  initial #1 $display("top data=%0d k=%0d", u_if.data, u_if.u_inner.k);
endmodule
