/*
:name: test_checker_procedures_reactive_renba
:description: In a checker, always_comb with a blocking assignment and a continuous assignment run in the Reactive region, and a nonblocking assignment of always_ff updates in the Re-NBA region after the Reactive and Re-Inactive regions are empty (IEEE 1800-2023 Section 17.7.3)
:tags: ch17
:type: simulation
:lrm: 1800-2023 17.7.3 24.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_checker_procedures_reactive_renba.expected
*/
// IEEE 1800-2023 §17.7.3: constructs of a checker that are sensitive to
// changes, such as continuous assignments and clocking events, and all its
// blocking statements are scheduled in the Reactive region, like programs
// (§24.3.1). Nonblocking assignments to checker variables update in the
// Re-NBA region, which is processed only after the Reactive and Re-Inactive
// regions are empty (§4.2).
// At time 10 the module sets sig to 1 and, after #0, reads the checker
// variables in the Inactive region, which comes before the Reactive region:
// comb_v (always_comb with a blocking assignment) and cont_v (continuous
// assignment) still hold 0. At time 11 both are 1.
// At time 20 clk rises. The program resumes in the Reactive region: the
// module always_ff has already updated mod_ff in the NBA region, while the
// checker always_ff has only scheduled its update of ff_v. After #0 the
// program runs in the Re-Inactive region, where ff_v is still 0. ff_v then
// changes in the Re-NBA region of the same time step, which wakes the
// program at time 20. Checker variables are only read, never assigned, by
// hierarchical name (§17.7.1).
// Icarus Verilog 13.0 does not compile checkers. Verilator 5.052 runs the
// checker procedures in the Active region (comb_v and cont_v are 1 after #0)
// and the program before the module NBA update (mod_ff is 0).

`timescale 1ns/1ns

checker crr_chk(logic clk, logic sig);
  bit comb_v;
  bit cont_v;
  int ff_v = 0;
  always_comb comb_v = sig;
  assign cont_v = sig;
  always_ff @(posedge clk) ff_v <= ff_v + 1;
endchecker

program crr_watch(input var bit clk);
  initial begin
    @(posedge clk);
    $display("reactive at %0t: ff_v=%0d mod_ff=%0d", $time,
             test_checker_procedures_reactive_renba.c.ff_v,
             test_checker_procedures_reactive_renba.mod_ff);
    #0;
    $display("re-inactive at %0t: ff_v=%0d", $time,
             test_checker_procedures_reactive_renba.c.ff_v);
    @(test_checker_procedures_reactive_renba.c.ff_v);
    $display("re-nba at %0t: ff_v=%0d", $time,
             test_checker_procedures_reactive_renba.c.ff_v);
  end
endprogram

module test_checker_procedures_reactive_renba;
  bit clk = 0, sig = 0;
  int mod_ff = 0;

  always_ff @(posedge clk) mod_ff <= mod_ff + 1;

  crr_chk c(clk, sig);
  crr_watch w(clk);

  initial begin
    #10 sig = 1;
    #0 $display("inactive at %0t: comb_v=%0d cont_v=%0d", $time, c.comb_v, c.cont_v);
    #1 $display("later at %0t: comb_v=%0d cont_v=%0d", $time, c.comb_v, c.cont_v);
    #9 clk = 1;
    #5 $finish;
  end
endmodule
