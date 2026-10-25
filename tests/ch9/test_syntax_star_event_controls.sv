/*
:name: test_syntax_star_event_controls
:description: "@*" and "@(*)" wait for every signal their statement reads and run the statement when one of them changes, with the value it reads (IEEE 1800-2023 Section 9.4.2, A.6.5)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.4 9.4.2 A.6.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_syntax_star_event_controls.expected
*/
// IEEE 1800-2023 A.6.5: an event control is a clocking event, "@*" or "@(*)".
// §9.4.2: "@*" and "@(*)" are the same implicit event control; it is
// sensitive to every signal read by the statement it controls. The two
// procedures below read one signal each and print it, so each prints once
// when its signal changes, with the new value. Verilator 5.052 runs such a
// procedure once at time 0 as well, which the standard does not require, so
// Icarus Verilog 13.0 records this expected output.

`timescale 1ns/1ns

module test_syntax_star_event_controls;
  logic a = 1'b0, b = 1'b0;

  always @* $display("%0t: star reads a=%b", $time, a);
  always @(*) $display("%0t: paren star reads b=%b", $time, b);

  initial begin
    #1 a = 1;
    #1 b = 1;
    #1 $finish;
  end
endmodule
