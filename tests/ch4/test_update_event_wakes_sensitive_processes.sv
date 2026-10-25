/*
:name: test_update_event_wakes_sensitive_processes
:description: Only a change of the value of a variable or net is an update event, and an update event wakes every process sensitive to it, as its event control filters it (IEEE 1800-2023 Section 4.3)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.3 4.5 9.4.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_update_event_wakes_sensitive_processes.expected
*/
// IEEE 1800-2023 §4.3: every change in the value of a net or variable is an
// update event, and processes sensitive to it are then evaluated, in an
// order that is not fixed. §4.5: applying an update event schedules an
// evaluation event for each process sensitive to it. §9.4.2: @(v) waits for
// any change of v, and posedge and negedge only for the matching change.
// Each process counts how often it wakes; the counts are printed at the end,
// so the order of the processes does not matter. They are cleared at time
// 1, after the time-0 initialization of the net n. Then v is written with
// its own value twice, which is no change, and with 1, 3 and 2: the two @(v)
// processes wake three times, posedge v[0] once (0 to 1), negedge v[0] once
// (1 to 0), and the net n = v & 1 changes twice (when v becomes 1 and when
// it becomes 2), so @(n) wakes twice.

module test_update_event_wakes_sensitive_processes;
  logic [1:0] v = 0;
  wire [1:0] n;
  int any_v = 0, any_v2 = 0, pos_v0 = 0, neg_v0 = 0, any_n = 0;

  assign n = v & 2'b01;

  always @(v) any_v++;
  always @(v) any_v2++;
  always @(posedge v[0]) pos_v0++;
  always @(negedge v[0]) neg_v0++;
  always @(n) any_n++;

  initial begin
    #1;
    any_v = 0;
    any_v2 = 0;
    pos_v0 = 0;
    neg_v0 = 0;
    any_n = 0;
    v = 0;
    #1 v = 1;
    #1 v = 1;
    #1 v = 3;
    #1 v = 2;
    #1 $display("@(v)=%0d @(v)=%0d posedge=%0d negedge=%0d @(n)=%0d", any_v, any_v2, pos_v0,
                neg_v0, any_n);
  end
endmodule
