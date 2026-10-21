/*
:name: test_property_nested_if_case
:description: a chain of property if-else statements checks the branch of the first condition that is true, and a property case whose item expressions are variables takes the first item that matches the case expression, even when a later one matches too (IEEE 1800-2023 Sections 16.12.6, 16.12.16)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.12.6 16.12.16 16.12.7 16.14.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_property_nested_if_case.expected
*/
// IEEE 1800-2023 §16.12.6: if (b) p1 else p2 is true when b is true and p1 is,
// or b is false and p2 is; with another if-else as p2, a chain checks the
// branch of the first true condition. §16.12.16: a property case compares
// the case expression with the item expressions in order and evaluates the
// property of the first item that matches, or the default item if none
// does; the item expressions can be variables. Both assertions start at a
// tick with go (§16.12.7), where m, n, sel, k1 and k2 are sampled; x, y and z
// are sampled at the next tick. The fail actions count the failures of each
// phase (§16.14.1). In the second phase m and n are both true and sel
// matches both k1 and k2: the first branch and the first item check x, which
// is low, while y, which the later ones would check, is high.

`timescale 1ns/1ns

module test_property_nested_if_case;
  logic clk = 0, go = 0, m = 0, n = 0, x = 0, y = 0, z = 0;
  logic [1:0] sel = 0, k1 = 0, k2 = 0;
  int f_if = 0, f_case = 0;

  always #5 clk = ~clk;   // ticks at 5, 15, 25, ...

  a_if: assert property (@(posedge clk) go |-> if (m) ##1 x else if (n) ##1 y else ##1 z)
    else f_if++;
  a_case: assert property (@(posedge clk) go |-> case (sel)
                                                   k1: ##1 x;
                                                   k2: ##1 y;
                                                   default: ##1 z;
                                                 endcase)
    else f_case++;

  // Runs one phase: go, m, n, sel, k1 and k2 at T, then x, y and z at T+1.
  task automatic phase(logic vm, logic vn, logic [1:0] vsel, logic [1:0] vk1, logic [1:0] vk2,
                       logic vx, logic vy, logic vz);
    go = 1; m = vm; n = vn; sel = vsel; k1 = vk1; k2 = vk2; #10;
    go = 0; m = 0; n = 0; sel = 0; k1 = 0; k2 = 0;
    x = vx; y = vy; z = vz; #10;
    x = 0; y = 0; z = 0; #10;
    $display("m %0d n %0d, sel %0d k1 %0d k2 %0d, x %0d y %0d z %0d: if %0d, case %0d",
             vm, vn, vsel, vk1, vk2, vx, vy, vz, f_if, f_case);
    f_if = 0;
    f_case = 0;
  endtask

  initial begin
    phase(0, 0, 0, 1, 2, 0, 0, 1);
    phase(1, 1, 1, 1, 1, 0, 1, 0);
    phase(0, 1, 2, 1, 2, 0, 1, 0);
    phase(0, 0, 3, 0, 0, 1, 1, 0);
    $finish;
  end
endmodule
