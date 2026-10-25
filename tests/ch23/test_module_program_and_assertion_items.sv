/*
:name: test_module_program_and_assertion_items
:description: A module common item can be a program instance and an assertion item, either a concurrent assertion or a static deferred assertion, and each of them takes effect (IEEE 1800-2023 Section 24.3)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.2.4 24.3 16.14.5 16.4.3 16.4.1 A.1.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_module_program_and_assertion_items.expected
*/
// IEEE 1800-2023 A.1.4: a module_common_item can be a program instance and an
// assertion item, which is a concurrent assertion or a deferred immediate
// assertion item.
//   - u_prog is an instance of the program mp_prog (24.3); its output doubled
//     is 2 * 21, and it prints at time 8. The end of its initial procedure
//     ends the simulation.
//   - a_conc (16.14.5) checks x == y with the sampled values at each posedge
//     of clk, at times 2 and 6: x is 1 and y is 0 at 2 (fail), both are 1 at
//     6 (pass).
//   - a_def is a static deferred assertion, which acts as if it were in an
//     always_comb procedure (16.4.3): it is checked at time 0 (pass), when x
//     changes at 1 (fail) and when y changes at 4 (pass). Its action block is
//     a single subroutine call, run after the report matures (16.4.1).
// Each action block prints the time, and no two lines share a time step.
// The $finish at 9 is only a guard; the program ends the simulation at 8.
// Icarus Verilog 13.0 does not support concurrent assertions. The 5.052
// release of Verilator checks the static deferred assertion again at times
// when neither x nor y changes (2, 6, 7, 8) and reports some checks twice,
// and it does not end the simulation when the program ends.

program mp_prog (input var int a, output int doubled);
  initial begin
    doubled = 2 * a;
    #8 $display("program a=%0d doubled=%0d", a, doubled);
  end
endprogram

module test_module_program_and_assertion_items;
  bit clk = 1'b0;
  int x = 0, y = 0;
  int pa = 21, pd;

  mp_prog u_prog (.a(pa), .doubled(pd));

  a_conc: assert property (@(posedge clk) x == y) $display("conc pass at %0d", $time);
    else $display("conc fail at %0d", $time);

  a_def: assert #0 (x == y) $display("deferred pass at %0d", $time);
    else $display("deferred fail at %0d", $time);

  always #2 clk = ~clk;
  initial begin
    #1 x = 1;
    #3 y = 1;
  end
  initial #7 $display("top pd=%0d", pd);
  initial #9 $finish;
endmodule
