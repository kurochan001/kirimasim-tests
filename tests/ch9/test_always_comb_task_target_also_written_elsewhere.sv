/*
:name: test_always_comb_task_target_also_written_elsewhere
:description: A variable assigned inside a task that an always_comb procedure calls is not a target restricted to the always_comb, so an initial procedure may also write it, and the variable shows each write in turn (IEEE 1800-2023 Section 9.2.2.2)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.2.2.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_always_comb_task_target_also_written_elsewhere.expected
*/
// IEEE 1800-2023 §9.2.2.2: the variables assigned by an always_comb shall
// not be assigned by any other process; this includes the variables assigned
// within the functions it calls, but not those assigned within the tasks it
// calls. The always_comb calls the task set_t, which has no timing control
// and assigns t, and the initial procedure writes t as well, so the design
// is legal. A tool that also counted the writes inside tasks would reject it.
// §9.2.2.2.1: the argument a + 10 of the task call is in the sensitivity list
// of the always_comb, while the contents of the task add nothing to it, and
// t is not read by the always_comb at all.
// - t1: the always_comb ran once at time zero, so t = 1 + 10 = 11.
// - t2: the initial procedure wrote 99 to t; the always_comb does not run
//   again, as none of its inputs changed, so t stays 99.
// - t3: a became 5, so the always_comb ran and set_t wrote 15 to t.
// - t4: the initial procedure wrote 77 to t.
// Each write comes 1 time unit before the line that shows it.
// The 5.054 release of Verilator prints t2 t=11: the write of 99 by the
// initial procedure does not stay, as if the always_comb ran again.

module test_always_comb_task_target_also_written_elsewhere;
  logic [7:0] a = 8'd1;
  logic [7:0] t;

  task automatic set_t(logic [7:0] v);
    t = v;
  endtask

  always_comb set_t(a + 8'd10);

  initial begin
    #1 $display("t1 t=%0d", t);
    t = 8'd99;
    #1 $display("t2 t=%0d", t);
    a = 8'd5;
    #1 $display("t3 t=%0d", t);
    t = 8'd77;
    #1 $display("t4 t=%0d", t);
  end
endmodule
