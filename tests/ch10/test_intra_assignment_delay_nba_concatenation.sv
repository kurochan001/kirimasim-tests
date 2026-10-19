/*
:name: test_intra_assignment_delay_nba_concatenation
:description: Nonblocking assignments with an intra-assignment delay, to a concatenation and to a variable, update in the NBA region of the later time step (IEEE 1800-2023 Section 10.4.2)
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.4.2 9.4.5 4.4.2.4
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_intra_assignment_delay_nba_concatenation.expected
*/
// IEEE 1800-2023 §10.4.2, §9.4.5: "lhs <= #2 rhs" evaluates rhs at once and
// schedules the update of lhs for the NBA region (4.4.2.4) of the time step
// 2 units later, also when lhs is a concatenation. A process that resumes
// in that time step reads the old values in the Active region and still
// after #0, in the Inactive region; the new values are there one time unit
// later.

module test_intra_assignment_delay_nba_concatenation;
  logic [3:0] a = 0, b = 0, s = 0;

  initial begin
    {a, b} <= #2 8'hbc;
    s <= #2 4'hd;
    #2 $display("t=%0d Active region: a=%h b=%h s=%h", $time, a, b, s);
    #0 $display("t=%0d after #0: a=%h b=%h s=%h", $time, a, b, s);
    #1 $display("t=%0d: a=%h b=%h s=%h", $time, a, b, s);
  end
endmodule
