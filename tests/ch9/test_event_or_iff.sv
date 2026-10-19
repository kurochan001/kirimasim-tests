/*
:name: test_event_or_iff
:description: The or and comma event operators, and iff conditions that are checked only when the event occurs (IEEE 1800-2023 Section 9.4.2.1)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.4.2.1 9.4.2.3 9.4.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_event_or_iff.expected
*/
// IEEE 1800-2023 §9.4.2.1: an event control with or, or with commas, wakes on
// any one of its events. §9.4.2.3: an event with iff wakes only if the iff
// expression is true when the event occurs; a change of the iff expression
// alone wakes nothing. iff binds more tightly than or, so
// posedge a iff en or posedge b wakes on posedge b whatever en is.
//
// The counts start at time 1, after the values are set at time 0.

module test_event_or_iff;
  bit a, b, en;
  int n_or, n_comma, n_iff, n_iff_or;

  always @(a or b) n_or++;
  always @(a, b) n_comma++;
  always @(posedge a iff en) n_iff++;
  always @(posedge a iff en or posedge b) n_iff_or++;

  initial begin
    a = 0; b = 0; en = 0;
    #1 n_or = 0; n_comma = 0; n_iff = 0; n_iff_or = 0;
    #1 a = 1;               // posedge a while en is 0
    #1 b = 1;               // posedge b
    #1 en = 1;              // only the iff expression changes
    #1 a = 0;               // negedge a
    #1 a = 1;               // posedge a while en is 1
    #1 a = 1; b = 1;        // no change
    #1 $display("n_or=%0d n_comma=%0d n_iff=%0d n_iff_or=%0d", n_or, n_comma, n_iff, n_iff_or);
  end
endmodule
