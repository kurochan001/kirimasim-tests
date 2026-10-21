/*
:name: test_sched_contassign_follows_nba
:description: A continuous assignment whose operand a nonblocking assignment updates gives its new value in the same time step (IEEE 1800-2023 Section 4.4.2.4)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.4.2.4 4.9.1 10.3 21.2.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sched_contassign_follows_nba.expected
*/
// IEEE 1800-2023 §4.9.1: a continuous assignment is evaluated again when an
// operand changes. The nonblocking update of x in the NBA region (§4.4.2.4)
// makes y follow within time 0, so $strobe (§21.2.2) shows both new values,
// while $display before the update shows the old ones.

module test_sched_contassign_follows_nba;
  int x = 1;
  wire [31:0] y;
  assign y = x + 1;
  initial begin
    #1;
    x <= 4;
    $display("display: x=%0d y=%0d", x, y);
    $strobe("strobe: x=%0d y=%0d", x, y);
  end
endmodule
