/*
:name: test_program_reactive_sees_nba
:description: The initial procedures and delays of a program run in the Reactive region, after the nonblocking updates of the design in the same time step (IEEE 1800-2023 Section 24.3.1)
:tags: ch24
:type: simulation
:lrm: 1800-2023 24.3.1 4.4.1 4.4.2.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_program_reactive_sees_nba.expected
*/
// IEEE 1800-2023 §24.3.1: an initial procedure in a program is scheduled in the
// Reactive region (4.4.2.6), and a # delay in a program resumes in the Reactive
// region too. The Reactive region set runs only after the Active region set of
// the time step, NBA region included, is done (4.4.1). So the program sees the
// values written by the design's nonblocking assignments of the same time step.
//
// Icarus Verilog 13.0 and Verilator 5.052 both print the values from before
// the nonblocking updates.

module test_program_reactive_sees_nba;
  logic [3:0] a = 0;

  initial begin
    a <= 4'd5;
    #1 a <= 4'd6;
  end

  program_reader p();
endmodule

program program_reader;
  initial begin
    $display("time 0: a=%0d", test_program_reactive_sees_nba.a);
    #1 $display("time 1: a=%0d", test_program_reactive_sees_nba.a);
  end
endprogram
