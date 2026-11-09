/*
:name: test_default_clocking_nested_module_scope
:description: a default clocking applies in its module and in a module declared inside it, but not in a separately declared module that the module instantiates, which uses its own default clocking (IEEE 1800-2023 Section 14.12)
:tags: ch14
:type: simulation
:lrm: 1800-2023 14.12 14.11 23.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_default_clocking_nested_module_scope.expected
*/
// IEEE 1800-2023 §14.12: a default clocking is valid in the scope that
// contains the default clocking statement: its module and the modules,
// interfaces and checkers declared inside it, but not the modules that it
// instantiates. §14.11: a cycle delay waits for that many events of the
// default clocking in effect. §23.4: inner is declared inside the test
// module and instantiated there, so the names of the test module, here its
// default clocking ca, are visible in it.
//
// ca is clocked by the posedge of clk_a (5, 15, 25, 35); own_clocked declares
// its own default clocking ob on the posedge of clk_b (2, 6, 10, ...). All
// three processes start their cycle delay at time 0. ##3 in the test module
// ends at the third ca event, 25; ##2 in the nested module inner ends at the
// second ca event, 15; ##2 in the instance of own_clocked ends at the second
// ob event, 6. A simulator that does not give inner the default clocking of
// its enclosing module rejects the cycle delay there, and one that applies
// the default clocking of the instantiating module inside own_clocked prints
// 15 for it.
// Icarus Verilog 13.0 does not support clocking blocks, and Verilator 5.052
// does not support module declarations inside modules.

`timescale 1ns/1ns

module own_clocked(input logic clk_b);
  int t_done = -1;
  default clocking ob @(posedge clk_b);
  endclocking
  initial begin
    ##2;
    t_done = $time;
  end
endmodule

module test_default_clocking_nested_module_scope;
  logic clk_a = 0, clk_b = 0;
  int t_outer = -1;

  always #5 clk_a = ~clk_a;
  always #2 clk_b = ~clk_b;

  default clocking ca @(posedge clk_a);
  endclocking

  module inner;
    int t_done = -1;
    initial begin
      ##2;
      t_done = $time;
    end
  endmodule

  inner u_inner();
  own_clocked u_own(clk_b);

  initial begin
    ##3;
    t_outer = $time;
  end

  initial begin
    #40;
    $display("outer module, ##3 of ca: t=%0d", t_outer);
    $display("nested module inner, ##2 of ca: t=%0d", u_inner.t_done);
    $display("instantiated module with its own default, ##2 of ob: t=%0d", u_own.t_done);
    $finish;
  end
endmodule
