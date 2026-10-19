/*
:name: test_property_if_else_case
:description: if (b) p is true when b is false or p holds, if (b) p1 else p2 checks the property of the branch b selects, and a property case evaluates the first matching item, the default when none matches, and is vacuously true when no item matches and there is no default (IEEE 1800-2023 Sections 16.12.6, 16.12.16)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.12.6 16.12.16 16.12.7 16.14.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_property_if_else_case.expected
*/
// IEEE 1800-2023 §16.12.6: if (b) p is true if b is false or p is true; if (b)
// p1 else p2 is true if b is true and p1 is, or b is false and p2 is.
// §16.12.16: a case property evaluates the property of the first item whose
// expression matches; without a match it evaluates the default item, and
// without a default it succeeds vacuously. Each assertion starts at a tick
// with go (§16.12.7); mode and sel are sampled at that tick. The fail actions
// count the failures of each phase (§16.14.1); each line shows the values of
// x at T+1 and T+2.

`timescale 1ns/1ns

module test_property_if_else_case;
  logic clk = 0, go = 0, mode = 0, x = 0;
  logic [1:0] sel = 0;
  int f_ifelse = 0, f_if = 0, f_case = 0, f_default = 0;

  always #5 clk = ~clk;   // ticks at 5, 15, 25, ...

  a_ifelse: assert property (@(posedge clk) go |-> if (mode) ##1 x else ##2 x) else f_ifelse++;
  a_if: assert property (@(posedge clk) go |-> if (mode) ##1 x) else f_if++;
  a_case: assert property (@(posedge clk) go |-> case (sel)
                                                   2'd0: ##1 x;
                                                   2'd1, 2'd2: ##2 x;
                                                 endcase)
    else f_case++;
  a_default: assert property (@(posedge clk) go |-> case (sel)
                                                      2'd0: ##1 x;
                                                      2'd1, 2'd2: ##2 x;
                                                      default: 1'b0;
                                                    endcase)
    else f_default++;

  // Runs one phase: go, mode and sel at T, then x at T+1 and T+2.
  task automatic phase(logic m, logic [1:0] s, logic x1, logic x2);
    go = 1; mode = m; sel = s; x = 0; #10;
    go = 0; x = x1; #10;
    x = x2; #10;
    x = 0; #20;
    $display("mode %0d, sel %0d, x %0d%0d: if-else %0d, if %0d, case %0d, default %0d",
             m, s, x1, x2, f_ifelse, f_if, f_case, f_default);
    f_ifelse = 0;
    f_if = 0;
    f_case = 0;
    f_default = 0;
  endtask

  initial begin
    phase(1, 0, 1, 0);
    phase(0, 1, 0, 1);
    phase(1, 2, 0, 1);
    phase(0, 3, 0, 0);
    $finish;
  end
endmodule
