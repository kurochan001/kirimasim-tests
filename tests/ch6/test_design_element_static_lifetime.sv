/*
:name: test_design_element_static_lifetime
:description: Variables outside tasks, processes and functions in a module, interface, program and checker have static lifetime even when the design element is automatic, and the same name in another design element is a different variable (IEEE 1800-2023 Section 6.21)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.21
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_design_element_static_lifetime.expected
*/
// IEEE 1800-2023 §6.21: a variable declared inside a module, interface,
// program or checker but outside a task, process or function is local in
// scope and has static lifetime, even when the design element is declared
// automatic. Each variable is written by one process at time zero and read
// by a different process later, so a per-process automatic variable would
// read its default value instead. Two design elements declare the same name
// to show that each name is local to its own element.

module automatic m_auto;
  int mv;
  initial mv = 3;
  initial #1 $display("module=%0d", mv);
endmodule

module other;
  int mv;
  initial mv = 9;
  initial #4 $display("other=%0d", mv);
endmodule

interface automatic if_auto;
  int iv;
  initial iv = 4;
  initial #2 $display("interface=%0d", iv);
endinterface

program automatic p_auto;
  int pv;
  initial pv = 5;
  initial #3 $display("program=%0d", pv);
endprogram

checker chk(input logic clk);
  int cv;
  initial cv = 6;
  always @(posedge clk) $display("checker=%0d", cv);
endchecker

module test_design_element_static_lifetime;
  logic clk = 0;
  if_auto i1();
  chk c1(clk);
  initial begin
    #6 clk = 1;
    #1 $finish;
  end
endmodule
