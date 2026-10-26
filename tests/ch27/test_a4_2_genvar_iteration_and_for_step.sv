/*
:name: test_a4_2_genvar_iteration_and_for_step
:description: A generate loop iterates a genvar with an assignment, a prefix increment and a postfix increment, and a for loop steps with an operator assignment, an increment expression and a subroutine call, so the sums show every form (IEEE 1800-2023 Sections 27.4 and 12.7.1, A.4.2 and A.6.8)
:tags: ch27
:type: simulation
:lrm: 1800-2023 27.4 12.7.1 A.4.2 A.6.8
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_a4_2_genvar_iteration_and_for_step.expected
*/
// IEEE 1800-2023 A.4.2: the iteration of a loop generate construct is an
// identifier with an assignment operator and a genvar expression, a prefix
// increment or decrement of the identifier, or a postfix one. A.6.8: a for
// step is a nonempty comma-separated list of operator assignments, increment
// or decrement expressions and function subroutine calls.
//
// Three generate loops add 1, 2 and 3 with g = g + 1, 10 twice with ++g and
// 100 twice with g++, which gives 226. Then a for loop with the step i += 1
// adds 1 three times, one with the step i++ adds 10 twice, and one whose step
// is the call add100() adds 100 twice from its body, which gives 223, and
// leaves i at 2. The order of the seven initial procedures is open, but the
// sum is the same in every order. Icarus Verilog 13.0 accepts neither a
// function nor a task call as a for step, so the expected output was
// recorded with Verilator 5.052.

`timescale 1ns/1ns
module test_a4_2_genvar_iteration_and_for_step;
  int total = 0;
  genvar g;

  generate
    for (g = 0; g < 3; g = g + 1) begin : assign_step
      initial total += g + 1;
    end
    for (g = 0; g < 2; ++g) begin : prefix_step
      initial total += 10;
    end
    for (g = 0; g < 2; g++) begin : postfix_step
      initial total += 100;
    end
  endgenerate

  int i;
  int k = 0;

  function void add100();
    k += 100;
  endfunction

  initial begin
    for (i = 0; i < 3; i += 1) k += 1;
    for (i = 0; i < 2; i++) k += 10;
    for (i = 0; i < 2; add100()) i += 1;
    #1 $display("total %0d", total);
    $display("k %0d i %0d", k, i);
  end
endmodule
