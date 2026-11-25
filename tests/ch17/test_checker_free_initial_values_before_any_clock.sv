/*
:name: test_checker_free_initial_values_before_any_clock
:description: Initial random draws for active inactive and const checker variables
:tags: ch17
:type: simulation
:lrm: 1800-2023 17.7.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: test_checker_free_initial_values_before_any_clock
:expected_stdout: initialized value preserved=1
*/
`timescale 1ns/1ns

checker initial_values(input bit solve_clock, write_clock,
                       output bit [63:0] active_out, inactive_out,
                       const_out, initialized_out);
  rand bit [63:0] active_var;
  rand bit [63:0] inactive_var;
  rand const bit [63:0] const_var;
  rand bit [63:0] initialized_var = 64'h2790c6e1fb53ad48;

  assign active_out = active_var;
  assign inactive_out = inactive_var;
  assign const_out = const_var;
  assign initialized_out = initialized_var;

  // The clocks never rise. The observer sees initialization, not an explicit
  // write or a draw at a later assume set event.
  always_ff @(posedge write_clock) inactive_var <= inactive_var + 1;
  active_constraint: assume property (@(posedge solve_clock) active_var[0]);
endchecker

module test_checker_free_initial_values_before_any_clock;
  bit solve_clock, write_clock;
  wire [63:0] active_out, inactive_out, const_out, initialized_out;
  initial_values u(solve_clock, write_clock, active_out, inactive_out,
                   const_out, initialized_out);

  initial begin
    #1;
    $display("initialized value preserved=%0d",
             initialized_out == 64'h2790c6e1fb53ad48);
    if ($test$plusargs("print-initial-values"))
      $display("draws active=%016h inactive=%016h const=%016h control=%08h",
               active_out, inactive_out, const_out, $urandom);
    $finish;
  end
endmodule
