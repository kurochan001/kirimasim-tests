/*
:name: test_syntax_wait_order_forms
:description: wait_order with a comma-separated list of event identifiers runs the statement before else when its events trigger from left to right, and the else statement when a later event triggers first (IEEE 1800-2023 Section 15.5.4, A.6.5)
:tags: ch15
:type: simulation
:lrm: 1800-2023 15.5 15.5.4 A.6.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_syntax_wait_order_forms.expected
*/
// IEEE 1800-2023 A.6.5: a wait statement is "wait ( expression )
// statement_or_null", "wait fork ;" or "wait_order (
// hierarchical_identifier { , hierarchical_identifier } ) action_block".
// §15.5.4: wait_order suspends until all of the events trigger from left to
// right; an event later in the list that triggers first fails the construct.
// The action block is a statement or null statement, or an optional
// statement before else and the else statement for failure.
//
// The first wait_order takes two events and prints its success statement when
// they trigger in order, at 3. The second triggers its second event first, so
// its else statement runs at 4 and the success statement does not. The third
// has the null statement as its success action and three events that trigger
// in order, so it succeeds without a message, and the print at 7 after it
// shows that execution continued.
//
// Icarus Verilog 13.0 and Verilator 5.052 do not support wait_order, so the
// expected output follows the standard.

`timescale 1ns/1ns

module test_syntax_wait_order_forms;
  event first, second, third;
  event ok_first, ok_second, ok_third;
  event late_first, late_second;

  initial begin
    fork
      wait_order (first, second) $display("%0t: two in order", $time);
      begin
        #1 -> first;
        #2 -> second;
      end
    join

    fork
      wait_order (late_first, late_second) $display("not printed");
        else $display("%0t: out of order", $time);
      begin
        #1 -> late_second;
      end
    join

    fork
      wait_order (ok_first, ok_second, ok_third) ;
      begin
        #1 -> ok_first;
        #1 -> ok_second;
        #1 -> ok_third;
      end
    join
    $display("%0t: null action returned", $time);

    $finish;
  end
endmodule
