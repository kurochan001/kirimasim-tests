/*
:name: test_unit_scope_name_space_item_kinds
:description: a function, a task, a checker, a parameter, a named event, a net, a variable and a user-defined type declared outside all design elements belong to the compilation-unit name space, so modules use each of them by its simple name, share the one object, and a module's own declaration of the same name is a different object (IEEE 1800-2023 Section 3.13)
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.13 3.12.1
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_unit_scope_name_space_item_kinds.expected
*/
// IEEE 1800-2023 §3.13 c): the compilation-unit name space, outside the
// modules, interfaces, packages, checkers, programs and primitives, unifies
// the functions, tasks, checkers, parameters, named events, nets, variables
// and user-defined types declared there. §3.12.1: such declarations are
// visible to the design elements of the compilation unit, and $unit:: names
// them explicitly. A parameter there is a local parameter (§6.20.4).
// One item of each kind is declared before the modules:
//   - unit_user_a drives the net unit_net with 42, and at 2 adds 1 to the
//     variable unit_var (7) and then triggers the event unit_ev;
//   - the top module waits for unit_ev and prints unit_var through $unit::
//     (8) and its own variable of the same name (99); the task unit_task,
//     declared outside the modules, reads the compilation-unit variable, so
//     it returns 8 + 100; unit_f multiplies by the parameter UNIT_P (5);
//     unit_word_t is a 12-bit type; and unit_net has the value that the
//     other module drives;
//   - the checker unit_chk, instantiated in the top module on unit_net,
//     prints the value from the pass action of its assertion at the one
//     rising clock edge, at 3.
// Icarus Verilog 13.0 stops with a syntax error at the net declaration
// outside the modules, which §3.13 c) and §3.12.1 allow.

parameter int UNIT_P = 5;
typedef logic [11:0] unit_word_t;
int unit_var = 7;
wire [7:0] unit_net;
event unit_ev;

function automatic int unit_f(int x);
  return x * UNIT_P;
endfunction

task automatic unit_task(output int o);
  o = unit_var + 100;
endtask

checker unit_chk(input logic clk, input logic [7:0] v);
  a_v: assert property (@(posedge clk) v == 8'd42) $display("unit_chk: v=%0d", v);
endchecker

module unit_user_a;
  assign unit_net = 8'd42;
  initial begin
    #2 unit_var = unit_var + 1;
    -> unit_ev;
  end
endmodule

module test_unit_scope_name_space_item_kinds;
  int unit_var = 99;
  logic clk = 1'b0;
  int got;
  unit_word_t w;

  unit_user_a u_a();
  unit_chk u_chk(clk, unit_net);

  initial begin
    @(unit_ev);
    $display("event: $unit::unit_var=%0d own unit_var=%0d", $unit::unit_var, unit_var);
    unit_task(got);
    $display("task: %0d", got);
    $display("function: %0d parameter: %0d", unit_f(3), UNIT_P);
    w = '1;
    $display("type: bits=%0d value=%0d", $bits(unit_word_t), w);
    $display("net: %0d", unit_net);
    #1 clk = 1'b1;
  end
endmodule
