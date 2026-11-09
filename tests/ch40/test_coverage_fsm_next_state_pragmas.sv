/*
:name: test_coverage_fsm_next_state_pragmas
:description: An enum pragma after the range of a separate declaration links a next-state signal to its FSM, and in a declaration of three signals the first is the current state, the second the next state and the third no part of the FSM, so FSM state coverage counts only the states the pragmas name (IEEE 1800-2023 Sections 40.4.4 and 40.4.5)
:tags: ch40
:type: simulation
:lrm: 1800-2023 40.4.4 40.4.5 40.4.1 40.4.6 40.4.7 40.2.2 40.3.2.1 40.3.2.2 40.3.2.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_coverage_fsm_next_state_pragmas.expected
*/
// IEEE 1800-2023 §40.4.4: the signal that holds the next state is linked to
// its FSM by the enum pragma written after its bit range. §40.4.5: when that
// pragma stands in a declaration of several signals, the first holds the
// current state, the second the next state, and nothing is assumed about the
// rest. §40.4.1: the state_vector pragma names the current state, here once
// with the enumeration name and once without it; §40.4.6 and §40.4.7: the
// parameters name the states, in one-line and block comments. §40.2.2: FSM
// coverage counts the states reached, and over an instance the coverage
// number is the sum over its FSMs.
//
// The first FSM is written as in Figure 40-2: cs is declared without a
// pragma, ns with the enum pragma, and the state_vector pragma names cs; its 3
// states are E0 to E2. The second is declared in one line: fs holds the
// current state, fs_next the next state and extra neither; its 2 states are F0
// and F1. So the instance has 5 states to cover (40.3.2.2): ns and fs_next
// are no FSMs of their own, and extra, which takes four values, is no FSM.
// Before the first clock edge at most the two reset states can have been
// reached; by time 40 every state has been assigned, so the current value
// (40.3.2.3) equals the maximum. These numbers hold where a start of FSM
// coverage of the instance at time 0 gives SV_COV_OK (40.3.2.1); the test
// prints whether they hold in that case, and the states at time 40.

`timescale 1ns/1ns

module test_coverage_fsm_next_state_pragmas_unit(input logic clk);
  logic [1:0] cs = 2'd0;
  logic [1:0] /* tool enum e_states */ ns;
  // tool state_vector cs enum e_states
  parameter // tool enum e_states
    E0 = 0,
    E1 = 1,
    E2 = 2;

  always_comb ns = cs == E2 ? E0 : cs + 2'd1;
  always @(posedge clk) cs <= ns;

  /* tool state_vector fs */
  logic [1:0] /* tool enum f_states */ fs = 2'd0, fs_next, extra = 2'd0;
  parameter [1:0] /* tool enum f_states */ F0 = 0, F1 = 1;

  always_comb fs_next = fs == F0 ? F1 : F0;
  always @(posedge clk) fs <= fs_next;
  always @(posedge clk) extra <= extra + 2'd1;
endmodule

module test_coverage_fsm_next_state_pragmas;
  logic clk = 0;
  int started, max_start, cur_start, max_end, cur_end;

  test_coverage_fsm_next_state_pragmas_unit u(.clk(clk));

  always #5 clk = ~clk;

  function automatic string yes_no(bit ok);
    return ok ? "yes" : "no";
  endfunction

  initial begin
    started = $coverage_control(`SV_COV_START, `SV_COV_FSM_STATE, `SV_COV_MODULE, u);
    #2;
    max_start = $coverage_get_max(`SV_COV_FSM_STATE, `SV_COV_MODULE, u);
    cur_start = $coverage_get(`SV_COV_FSM_STATE, `SV_COV_MODULE, u);
    #38;
    max_end = $coverage_get_max(`SV_COV_FSM_STATE, `SV_COV_MODULE, u);
    cur_end = $coverage_get(`SV_COV_FSM_STATE, `SV_COV_MODULE, u);
    $display("with FSM coverage started, the maximum is the 5 states named: %s",
             yes_no(started != `SV_COV_OK || (max_start == 5 && max_end == 5)));
    $display("with FSM coverage started, before the first edge the current value is below it: %s",
             yes_no(started != `SV_COV_OK || cur_start < max_start));
    $display("with FSM coverage started, at time 40 the current value is the maximum: %s",
             yes_no(started != `SV_COV_OK || cur_end == max_end));
    $display("states at time 40: cs %0d, fs %0d, extra %0d", u.cs, u.fs, u.extra);
    $finish;
  end
endmodule
