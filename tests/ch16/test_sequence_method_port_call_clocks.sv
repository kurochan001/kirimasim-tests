/*
:name: test_sequence_method_port_call_clocks
:description: Sequence methods used in module, interface and program port actuals use the instantiation clock, and methods in task and function actuals use the call-site clock (IEEE 1800-2023 Section 16.13.6)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.13.6 16.9.3 16.14.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sequence_method_port_call_clocks.expected
*/
// 16.13.6 B020 clocks a method-bearing sequence at the instantiation or
// task/function call site. B017 and 16.9.3 B006 resolve a method in an
// assertion action using that assertion's leading clock, and a port actual
// outside a procedure using the default clocking at the instantiation.
// The unclocked sequence is x ##1 y. x is true during 10..20 and 40..50,
// y during 20..30 and 50..60. The caller's default clock rises at 5+10*k,
// so the three port actuals first match at 25. Their recipients each have
// a different default clock, 2+10*k, which would instead match at 22.
// The two calls occur in a pass action clocked at 7+10*k, so their methods
// match at 27 and 57, rather than at the enclosing default's 25 and 55.
// All action blocks run after the Observed region sets triggered (16.13.6
// B005); no Active-region read is used. Each recipient waits for just the
// first true input, avoiding any dependence on reset of triggered emitting
// an event. Separate variables are printed at 63, away from every clock.

`timescale 1ns/1ns

module port_clock_module(input logic wrong_clk, input logic hit,
                         output time first_hit);
  default clocking wrong_cb @(posedge wrong_clk); endclocking
  initial begin
    wait (hit);
    first_hit = $time;
  end
endmodule

interface port_clock_interface(input logic wrong_clk, input logic hit,
                               output time first_hit);
  default clocking wrong_cb @(posedge wrong_clk); endclocking
  initial begin
    wait (hit);
    first_hit = $time;
  end
endinterface

program port_clock_program(input logic wrong_clk, input logic hit,
                           output time first_hit);
  default clocking wrong_cb @(posedge wrong_clk); endclocking
  initial begin
    wait (hit);
    first_hit = $time;
    wait (1'b0); // Keep the program alive until the top calls $finish.
  end
endprogram

module test_sequence_method_port_call_clocks;
  logic default_clk = 0, wrong_clk = 0, call_clk = 0;
  bit x = 0, y = 0;
  time module_hit, interface_hit, program_hit;
  string task_hits = "", function_hits = "";
  default clocking caller_cb @(posedge default_clk); endclocking

  sequence pair_s;
    x ##1 y;
  endsequence

  port_clock_module um(wrong_clk, pair_s.triggered, module_hit);
  port_clock_interface ui(wrong_clk, pair_s.triggered, interface_hit);
  port_clock_program up(wrong_clk, pair_s.triggered, program_hit);

  task automatic record_task(input bit hit);
    if (hit) task_hits = {task_hits, $sformatf(" %0d", $time)};
  endtask

  function automatic bit echo_hit(input bit hit);
    return hit;
  endfunction

  a_calls: assert property (@(posedge call_clk) 1'b1) begin
    record_task(pair_s.triggered);
    if (echo_hit(pair_s.triggered))
      function_hits = {function_hits, $sformatf(" %0d", $time)};
  end

  initial begin
    #5 forever begin default_clk = 1; #5 default_clk = 0; #5; end
  end
  initial begin
    #2 forever begin wrong_clk = 1; #5 wrong_clk = 0; #5; end
  end
  initial begin
    #7 forever begin call_clk = 1; #5 call_clk = 0; #5; end
  end

  initial begin
    #10 x = 1;
    #10 x = 0; y = 1;
    #10 y = 0;
    #10 x = 1;
    #10 x = 0; y = 1;
    #10 y = 0;
    #3;
    $display("ports module=%0d interface=%0d program=%0d",
             module_hit, interface_hit, program_hit);
    $display("task hits:%s", task_hits);
    $display("function hits:%s", function_hits);
    $finish;
  end
endmodule
