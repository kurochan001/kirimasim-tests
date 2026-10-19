/*
:name: test_coverage_fsm_pragmas
:description: FSM recognition pragmas in block and one-line comments name state vectors, part-selects, concatenations, next-state signals and state parameters without changing how the design simulates (IEEE 1800-2023 Section 40.4)
:tags: ch40
:type: simulation
:lrm: 1800-2023 40.4 40.4.1 40.4.2 40.4.3 40.4.4 40.4.5 40.4.6 40.4.7 5.4
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_coverage_fsm_pragmas.expected
*/
// IEEE 1800-2023 §40.4: the pragmas that tell a coverage tool which signals
// hold the state of an FSM are written inside comments: a block comment naming
// the state vector (40.4.1), a part-select (40.4.2) or a concatenation (40.4.3)
// with an FSM name, an enum pragma right after the bit range of a declaration
// whose first signal holds the current and second the next state (40.4.4,
// 40.4.5), and enum pragmas on the state parameters (40.4.6), also in a
// one-line comment (40.4.7). Being comments (5.4), they do not change the
// simulation: the three FSMs step through their states as the code says.

module test_coverage_fsm_pragmas;
  logic clk = 0;

  always #5 clk = ~clk;

  // Current and next state in one declaration.
  /* tool state_vector st */
  logic [1:0] /* tool enum shift_states */ st = 0, st_next;
  parameter [1:0] // tool enum shift_states
    IDLE = 0,
    LOAD = 1,
    SHIFT = 2,
    DONE = 3;

  always_comb
    case (st)
      IDLE: st_next = LOAD;
      LOAD: st_next = SHIFT;
      SHIFT: st_next = DONE;
      default: st_next = IDLE;
    endcase

  always @(posedge clk) st <= st_next;

  // State in a part-select.
  /* tool state_vector ctl[3:2] mode_fsm enum mode_states */
  logic [3:0] ctl = 4'b0000;
  parameter /* tool enum mode_states */ M_OFF = 0, M_ON = 1, M_HOLD = 2;

  always @(posedge clk) ctl[3:2] <= ctl[3:2] == M_HOLD ? M_OFF : ctl[3:2] + 1;

  // State in a concatenation.
  /* tool state_vector {hi, lo} pair_fsm enum pair_states */
  logic hi = 0, lo = 0;
  parameter [1:0] /* tool enum pair_states */ P0 = 2'b00, P1 = 2'b01, P2 = 2'b11;

  always @(posedge clk) {hi, lo} <= {hi, lo} == P2 ? P0 : {hi, lo} == P0 ? P1 : P2;

  initial begin
    repeat (5) begin
      @(negedge clk);
      $display("%0d: st %0d, mode %0d, pair %b%b", $time, st, ctl[3:2], hi, lo);
    end
    $finish;
  end
endmodule
