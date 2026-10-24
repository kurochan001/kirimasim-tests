/*
:name: test_interface_members_processes_and_types
:description: An interface between interface and endinterface has a value parameter, a type parameter, a localparam and a const, a typedef, variables, a function, a task, an initial and an always procedure and a continuous assignment, and the module uses them through the instance name (IEEE 1800-2023 Section 3.5)
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.5 25.3 25.8 6.20.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_interface_members_processes_and_types.expected
*/
// IEEE 1800-2023 §3.5: an interface, enclosed by interface and endinterface,
// can have parameters, constants, variables, functions and tasks, the types
// of its items can be declared in it or passed in as type parameters, and it
// can contain initial and always procedures and continuous assignments. Its
// variables and subroutines are referenced relative to the instance name.
// bus is an instance of members_if with WIDTH = 6 and item_t = logic [11:0]
// (the defaults are 4 and byte, §25.8, §6.20.3):
// - word_t, declared in the interface from WIDTH, has 6 bits, so MAXV is 63
//   and add_offset(62) wraps to 1 (62 + OFFSET 3 = 65 in 6 bits), while
//   add_offset(60) is 63;
// - item is of the passed type: 12 bits and unsigned, so -1 reads as 4095;
// - the task put waits for the next rising clock edge (time 5) and writes
//   data; the continuous assignment gives inv = ~data; the always procedure
//   counts rising edges; the initial procedure sets mark to 77.
// The module calls the task and the functions and reads the variables as
// bus.<name>, and prints them at time 6 and 16, away from the clock edges.

`timescale 1ns/1ns

interface members_if #(parameter int WIDTH = 4, parameter type item_t = byte)
                      (input logic clk);
  localparam int MAXV = (1 << WIDTH) - 1;
  const int OFFSET = 3;
  typedef logic [WIDTH-1:0] word_t;

  word_t data;
  word_t inv;
  item_t item;
  int ticks = 0;
  int mark = 0;

  assign inv = ~data;

  always @(posedge clk) ticks <= ticks + 1;

  initial mark = 77;

  function automatic word_t add_offset(word_t v);
    return v + OFFSET;
  endfunction

  task automatic put(input word_t v);
    @(posedge clk);
    data = v;
  endtask
endinterface : members_if

module test_interface_members_processes_and_types;
  logic clk = 0;

  always #5 clk = ~clk;

  members_if #(.WIDTH(6), .item_t(logic [11:0])) bus(.clk(clk));

  initial begin
    bus.item = -1;
    bus.put(6'd9);
    $display("t=%0t put returned", $time);
    #1;
    $display("t=%0t data=%0d inv=%b ticks=%0d mark=%0d", $time, bus.data, bus.inv,
             bus.ticks, bus.mark);
    $display("params: MAXV=%0d bits(data)=%0d bits(item)=%0d item=%0d", bus.MAXV,
             $bits(bus.data), $bits(bus.item), bus.item);
    $display("function: add_offset(60)=%0d add_offset(62)=%0d", bus.add_offset(60),
             bus.add_offset(62));
    #10;
    $display("t=%0t ticks=%0d", $time, bus.ticks);
    $finish;
  end
endmodule
