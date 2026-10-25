/*
:name: test_defparam_targets_module_interface_program
:description: defparam statements change value parameters of module, interface and program instances, named by a downward hierarchical name, by a name from the top-level module, and from another top-level module (IEEE 1800-2023 Section 23.10.1)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.10.1 23.6 24.3 25.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_defparam_targets_module_interface_program.expected
*/
// IEEE 1800-2023 §23.10.1: a defparam statement changes a value parameter
// of a module, interface or program instance anywhere in the design, named
// by its hierarchical name (§23.6), which may go down from the module of the
// statement or start at a top-level module.
//   m.P (module instance m) is set to 5 by a downward name;
//   ifc.W (interface instance ifc) is set to 7 by a name from the top;
//   prg.Q (program instance prg) is set to 9;
//   sub.n.D (module instance n inside the module instance sub) is set to 11
//   from the separate top-level module defparam_targets_mip_annotate.
// The parameters that no defparam names keep their defaults: m.K stays 1.
// The top module prints at time 1 and the program at time 2.

module defparam_targets_mip_m;
  parameter int P = 0;
  parameter int K = 1;
endmodule

module defparam_targets_mip_n;
  parameter int D = 0;
endmodule

module defparam_targets_mip_sub;
  defparam_targets_mip_n n();
endmodule

interface defparam_targets_mip_if;
  parameter int W = 0;
endinterface

program defparam_targets_mip_p;
  parameter int Q = 0;
  initial #2 $display("prg.Q=%0d", Q);
endprogram

module test_defparam_targets_module_interface_program;
  defparam_targets_mip_m m();
  defparam_targets_mip_if ifc();
  defparam_targets_mip_p prg();
  defparam_targets_mip_sub sub();

  defparam m.P = 5;
  defparam test_defparam_targets_module_interface_program.ifc.W = 7;
  defparam prg.Q = 9;

  initial #1 $display("m.P=%0d m.K=%0d ifc.W=%0d sub.n.D=%0d", m.P, m.K, ifc.W, sub.n.D);
endmodule

module defparam_targets_mip_annotate;
  defparam test_defparam_targets_module_interface_program.sub.n.D = 11;
endmodule
