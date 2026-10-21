/*
:name: test_coverage_fsm_pragma_states
:description: Where FSM state coverage is started successfully, its maximum for an instance is the number of states that the FSM pragmas name, for state vectors given as a signal with its next-state signal, a part-select and a concatenation, also in one-line comments, and every state counts once reached (IEEE 1800-2023 Sections 40.4.2 to 40.4.7)
:tags: ch40
:type: simulation
:lrm: 1800-2023 40.4.2 40.4.3 40.4.4 40.4.5 40.4.7 40.4 40.4.6 40.2.2 40.3.2.1 40.3.2.2 40.3.2.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_coverage_fsm_pragma_states.expected
*/
// IEEE 1800-2023 §40.4: FSM pragmas override a tool's own FSM extraction. The
// unit has three FSMs: sa, with its next state sa_next in the same declaration
// (40.4.4, 40.4.5); the part-select ctl[2:1], named b_fsm (40.4.2); and the
// concatenation {hi, lo}, named c_fsm (40.4.3). Two of the pragmas are in
// one-line comments (40.4.7). The parameters name 4, 3 and 3 states (40.4.6).
// §40.2.2: FSM coverage counts the states an FSM has reached, and over an
// instance the coverage number is the sum over its FSMs, so the maximum of the
// instance (40.3.2.2) is 10 and sa_next is no FSM of its own. At time 20 sa
// has not been in A3 yet, so the current value (40.3.2.3) is below the
// maximum; by time 40 each FSM has been assigned all of its states, so it
// equals the maximum. These numbers hold where a start of FSM coverage of the
// instance at time 0 gives OK (40.3.2.1), so that it is collected from then
// on, which depends on the tool; the test prints whether they hold in that
// case, and the states at time 40.

`timescale 1ns/1ns

module test_coverage_fsm_pragma_states_unit (input logic clk);
  // tool state_vector sa
  logic [1:0] /* tool enum a_states */ sa = 0, sa_next;
  parameter [1:0] // tool enum a_states
    A0 = 0,
    A1 = 1,
    A2 = 2,
    A3 = 3;

  always_comb
    case (sa)
      A0: sa_next = A1;
      A1: sa_next = A2;
      A2: sa_next = A3;
      default: sa_next = A0;
    endcase

  always @(posedge clk) sa <= sa_next;

  /* tool state_vector ctl[2:1] b_fsm enum b_states */
  logic [3:0] ctl = 4'b0000;
  parameter /* tool enum b_states */ B0 = 0, B1 = 1, B2 = 2;

  always @(posedge clk) ctl[2:1] <= ctl[2:1] == B2 ? B0 : ctl[2:1] + 1;

  // tool state_vector {hi, lo} c_fsm enum c_states
  logic hi = 0, lo = 0;
  parameter [1:0] /* tool enum c_states */ C0 = 2'b00, C1 = 2'b01, C2 = 2'b11;

  always @(posedge clk) {hi, lo} <= {hi, lo} == C0 ? C1 : {hi, lo} == C1 ? C2 : C0;
endmodule

module test_coverage_fsm_pragma_states;
  logic clk = 0;
  int started, max_mid, cur_mid, max_end, cur_end;

  test_coverage_fsm_pragma_states_unit u(.clk(clk));

  always #5 clk = ~clk;

  function automatic string yes_no(bit ok);
    return ok ? "yes" : "no";
  endfunction

  initial begin
    started = $coverage_control(`SV_COV_START, `SV_COV_FSM_STATE, `SV_COV_MODULE, u);
    #20;
    max_mid = $coverage_get_max(`SV_COV_FSM_STATE, `SV_COV_MODULE, u);
    cur_mid = $coverage_get(`SV_COV_FSM_STATE, `SV_COV_MODULE, u);
    #20;
    max_end = $coverage_get_max(`SV_COV_FSM_STATE, `SV_COV_MODULE, u);
    cur_end = $coverage_get(`SV_COV_FSM_STATE, `SV_COV_MODULE, u);
    $display("with FSM coverage started, the maximum is the 10 states named: %s",
             yes_no(started != `SV_COV_OK || (max_mid == 10 && max_end == 10)));
    $display("with FSM coverage started, at time 20 the current value is below it: %s",
             yes_no(started != `SV_COV_OK || cur_mid < max_mid));
    $display("with FSM coverage started, at time 40 the current value is the maximum: %s",
             yes_no(started != `SV_COV_OK || cur_end == max_end));
    $display("states at time 40: sa %0d, ctl[2:1] %0d, {hi, lo} %b%b", u.sa, u.ctl[2:1], u.hi,
             u.lo);
    $finish;
  end
endmodule
