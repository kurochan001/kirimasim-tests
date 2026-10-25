/*
:name: test_hierarchical_identifier_forms_through_instances
:description: A hierarchical name reaches a net, a variable, a named block, a generate block with its index and local parameter, an event, a parameter, a task and a function of an instance, with bit and part selects and a struct member, and also a parameter and a function of a package (IEEE 1800-2023 Section 23.6)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.6 23.7 6.20.4 27.4 A.9.3 A.8.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_hierarchical_identifier_forms_through_instances.expected
*/
// IEEE 1800-2023 A.9.3: a hierarchical identifier is an identifier, further
// identifiers after dots, each optionally with a constant bit select, and a
// final identifier; the hierarchical forms of net, variable, block, event,
// parameter, task, tf and array identifiers are hierarchical identifiers. A
// package-scoped parameter and a parameter in a generate block are
// ps_parameter_identifiers. A.8.4: a hierarchical identifier with a select is
// a primary. §23.6: a hierarchical name reaches the named object through the
// instance and block scopes. §23.7: a parameter of an instance is reachable
// as a hierarchical parameter. §6.20.4: a localparam in a generate block is
// reachable through the generate block name and index. §27.4: each generate
// block of a loop has its genvar value as index.
//
// The instance u of leaf has the parameter P = 2, the input din = 4'h3, so
// dout is 5 and the reduction XOR n1 is 0; v is 3, mem[1] is 8'h5A, the
// struct member st.hi is 4'hA and st.lo[1:0] is 1. The two generate blocks
// have gv 1 and 2 and the localparams 10 and 11, and the parameter sum is
// 2 + 10 + hp::PP = 2 + 10 + 7 = 19. u.f_add(5) is 7 and hp::pfun(3) is 4.
// hp::parr[1] is 5 and u.mem[2] is 8'hA5. The named block inner of u has the
// variable bx = 6. The event u.ev is triggered at time 2, so the process that
// waits for it prints event, and the time 3 is printed after it.
//
// Icarus Verilog 13.0 produces this output but has no $root, which the next
// test of this clause covers with Verilator. Verilator 5.052 cannot reach a
// localparam of a generate block.

`timescale 1ns/1ns

package hp;
  int parr [2] = '{4, 5};
  parameter int PP = 7;

  function automatic int pfun(int a);
    return a + 1;
  endfunction
endpackage

module leaf #(parameter int P = 2) (input logic [3:0] din,
                                    output logic [3:0] dout);
  typedef struct packed { logic [3:0] hi; logic [3:0] lo; } pair_t;

  logic [3:0] v;
  logic [7:0] mem [0:3];
  wire n1;
  pair_t st;
  event ev;

  assign dout = din + P;
  assign n1 = ^din;

  function automatic int f_add(int a);
    return a + P;
  endfunction

  task automatic t_show(output int r);
    r = P * 2;
  endtask

  initial begin
    v = din;
    mem[0] = 8'h11;
    mem[1] = 8'h5A;
    mem[2] = 8'hA5;
    mem[3] = 8'h44;
    st.hi = 4'hA;
    st.lo = 4'h5;
  end

  initial begin : inner
    int bx;
    bx = 6;
  end
endmodule

module test_hierarchical_identifier_forms_through_instances;
  logic [3:0] d = 4'h3;
  int r, sum;

  leaf u (.din(d), .dout());

  for (genvar g = 0; g < 2; g++) begin : blk
    localparam int LP = g + 10;
    logic [3:0] gv;
    assign gv = g + 1;
  end

  initial begin
    #1;
    u.t_show(r);
    $display("net %b %b", u.n1, u.dout);
    $display("var %h %h %h", u.v, u.mem[1], u.st.hi);
    $display("sel %h %b %h", u.mem[1][7:4], u.v[3:2], u.st.lo[1:0]);
    $display("gen %0d %0d", blk[0].gv, blk[1].gv);
    sum = u.P + blk[0].LP + hp::PP;
    $display("param %0d %0d", u.P, sum);
    $display("call %0d %0d", u.f_add(5), hp::pfun(3));
    $display("arr %0d %h", hp::parr[1], u.mem[2]);
    $display("blk %0d", u.inner.bx);
    #1;
    -> u.ev;
    #1 $display("ev %0d", $time);
  end

  initial begin
    @(u.ev);
    $display("event");
  end
endmodule
