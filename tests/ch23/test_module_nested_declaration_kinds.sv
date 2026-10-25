/*
:name: test_module_nested_declaration_kinds
:description: A module item can be a nested module, interface or program declaration; the nested module and program without ports are instantiated implicitly once, the nested interface is instantiated explicitly, and all of them see the names of the outer module (IEEE 1800-2023 Section 23.4)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.4 24.3 25.3 A.1.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_module_nested_declaration_kinds.expected
*/
// IEEE 1800-2023 A.1.4: a non_port_module_item can be a module declaration,
// an interface declaration or a program declaration. §23.4: the names of the
// outer module are visible in a nested module, and a nested module without
// ports that is not instantiated is instantiated once implicitly, with the
// module name as the instance name. §24.3: the same holds for a nested
// program without ports. §25.3: an interface is never instantiated
// implicitly, so the nested interface nm_bus is instantiated as u_bus.
//   - nm_child sets got = base + 1 = 8 from the outer variable base;
//   - u_bus sets v = base * 2 = 14;
//   - nm_prog prints both at time 2; the end of its only initial procedure
//     ends the simulation (24.3), after the line of the outer module at 1.
// Icarus Verilog 13.0 does not find the nested interface ("Unknown module
// type"), though it prints the expected values for the nested module and
// program without it; the 5.052 release of Verilator does not support module
// declarations within module declarations.

module test_module_nested_declaration_kinds;
  int base = 7;

  module nm_child;
    int got;
    initial got = base + 1;
  endmodule

  interface nm_bus;
    int v;
    initial v = base * 2;
  endinterface
  nm_bus u_bus();

  program nm_prog;
    initial #2 $display("prog child=%0d bus=%0d", nm_child.got, u_bus.v);
  endprogram

  initial #1 $display("outer child=%0d bus=%0d", nm_child.got, u_bus.v);
endmodule
