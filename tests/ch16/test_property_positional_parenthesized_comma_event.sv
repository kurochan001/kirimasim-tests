/*
:name: test_property_positional_parenthesized_comma_event
:description: Parentheses keep a comma-separated event expression in one positional property argument
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.8.1 A.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_property_positional_parenthesized_comma_event.expected
*/
`timescale 1ns/1ns
module test_property_positional_parenthesized_comma_event;
  bit clock_a, clock_b;
  bit armed = 1;
  int hits;

  property on_tick(event tick, bit enabled);
    @(tick) enabled;
  endproperty

  cover property (on_tick((posedge clock_a, posedge clock_b), armed)) begin
    hits++;
    $display("cover t=%0d", int'($time));
  end

  initial begin
    #3 clock_a = 1;
    #3 clock_b = 1;
    #2 armed = 0;
    #1 clock_a = 0;
    #1 clock_a = 1;
    #1 $display("hits=%0d", hits);
    $finish;
  end
endmodule
