/*
:name: test_default_disable_iff_scopes
:description: a default disable iff of a module reaches its generate blocks, resolves its names in its own scope, is replaced inside a generate block that declares its own default, does not reach the instances of a module, an interface and a program declared elsewhere, which then have no disable condition, and interfaces and programs can declare their own (IEEE 1800-2023 Section 16.15)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.15 27.5 24.3 16.12 16.14.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_default_disable_iff_scopes.expected
*/
// IEEE 1800-2023 §16.15: a default disable iff may be declared in a module,
// interface or program declaration or in a generate block; it applies to the
// concurrent assertions of that scope and of its nested generate blocks
// (§27.5), unless such a block declares its own default, which then applies
// inside it. Its names resolve in the scope of the declaration. It does not
// extend into instances of modules, interfaces or programs; an assertion
// that is in the scope of no default and has no disable iff gets no disable
// condition. Here every assertion checks a |=> b, with a high at one tick of
// each phase and b always low, so each attempt fails one tick later (§16.12)
// unless it is disabled. In each phase one disable signal is high during that
// attempt; the fail actions (§16.14.1) count the failures, and each line
// names the assertions that failed in that phase. The top default is rst.
// g_shadow declares its own rst, always 0, which the default does not use.
// g_inner declares default disable iff r_gen. child_m, plain_i and plain_p,
// declared outside without a default, are instantiated in the top module.
// The interface ifc_i and the program prg_p (§24.3) declare default disable
// iff r_if and r_pg. The programs pass their counts out through a port.

`timescale 1ns/1ns

module child_m(input logic clk, a, b);
  int f = 0;
  a_child: assert property (@(posedge clk) a |=> b) else f++;
endmodule

interface ifc_i(input logic clk, a, b, r_if);
  int f = 0;
  default disable iff r_if;
  a_if: assert property (@(posedge clk) a |=> b) else f++;
endinterface

program prg_p(input logic clk, a, b, r_pg, output int f_pg);
  default disable iff r_pg;
  a_prog: assert property (@(posedge clk) a |=> b) else f_pg++;
endprogram

interface plain_i(input logic clk, a, b);
  int f = 0;
  a_plain_if: assert property (@(posedge clk) a |=> b) else f++;
endinterface

program plain_p(input logic clk, a, b, output int f_pg);
  a_plain_prog: assert property (@(posedge clk) a |=> b) else f_pg++;
endprogram

module test_default_disable_iff_scopes;
  logic clk = 0, a = 0, b = 0, rst = 0, r_gen = 0, r_if = 0, r_pg = 0;
  int f_top = 0, f_prog, f_plain_prog;

  always #5 clk = ~clk;   // ticks at 5, 15, 25, ...

  default disable iff rst;

  a_top: assert property (@(posedge clk) a |=> b) else f_top++;

  if (1) begin : g_plain
    int f = 0;
    a_plain: assert property (@(posedge clk) a |=> b) else f++;
  end

  if (1) begin : g_shadow
    logic rst = 0;
    int f = 0;
    a_shadow: assert property (@(posedge clk) a |=> b) else f++;
  end

  if (1) begin : g_inner
    int f = 0;
    default disable iff r_gen;
    a_inner: assert property (@(posedge clk) a |=> b) else f++;
  end

  child_m u_child(.clk(clk), .a(a), .b(b));
  ifc_i u_if(.clk(clk), .a(a), .b(b), .r_if(r_if));
  prg_p u_prog(.clk(clk), .a(a), .b(b), .r_pg(r_pg), .f_pg(f_prog));
  plain_i u_plain_if(.clk(clk), .a(a), .b(b));
  plain_p u_plain_prog(.clk(clk), .a(a), .b(b), .f_pg(f_plain_prog));

  int last[9];

  // Names the assertions whose failure count grew since the last call.
  function automatic string failed();
    int now[9] = '{f_top, g_plain.f, g_shadow.f, g_inner.f, u_child.f, u_if.f, f_prog,
                   u_plain_if.f, f_plain_prog};
    string names[9] = '{"top", "g_plain", "g_shadow", "g_inner", "child", "interface",
                        "program", "plain_i", "plain_p"};
    string s = "";
    foreach (now[i]) if (now[i] != last[i]) s = {s, " ", names[i]};
    last = now;
    return s;
  endfunction

  // One phase of 30 time units: a for the tick at +5, which is checked at +15;
  // the disable signal chosen by k is high from +0 to +20.
  task automatic run_phase(int k, string what);
    {rst, r_gen, r_if, r_pg} = 4'b1000 >> k;
    a = 1;
    #10 a = 0;
    #10 {rst, r_gen, r_if, r_pg} = 4'b0000;
    #8 $display("%s high: failed:%s", what, failed());
    #2;
  endtask

  initial begin
    run_phase(0, "rst");
    run_phase(1, "r_gen");
    run_phase(2, "r_if");
    run_phase(3, "r_pg");
    run_phase(4, "nothing");
    $finish;
  end
endmodule
