/*
:name: test_repeat_count_evaluated_once
:description: A repeat loop evaluates its count expression once before the first iteration and runs that many iterations, even when the body changes the variables of the expression (IEEE 1800-2023 Section 12.7.2)
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.7.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_repeat_count_evaluated_once.expected
*/
// IEEE 1800-2023 §12.7.2: a repeat loop evaluates its expression once,
// before the loop starts, and runs its statement that many times; changing
// any part of the expression inside the loop has no effect.
//
// The first loop repeats n times and sets n to 10 in its body; the second
// repeats a + b times and increments a and decrements b; the third uses a
// function call that counts its calls and returns 4. Each prints the number
// of iterations and the final values.

module test_repeat_count_evaluated_once;
  int n, a, b, count, calls;

  function automatic int times();
    calls++;
    return 4;
  endfunction

  initial begin
    n = 3;
    count = 0;
    repeat (n) begin
      count++;
      n = 10;
    end
    $display("repeat (n), n = 3 then 10 in the body: %0d iterations, n=%0d", count, n);

    a = 2;
    b = 3;
    count = 0;
    repeat (a + b) begin
      count++;
      a++;
      b--;
      b--;
    end
    $display("repeat (a + b), a + b = 5 at the start: %0d iterations, a=%0d b=%0d", count, a, b);

    calls = 0;
    count = 0;
    repeat (times()) count++;
    $display("repeat (times()): %0d iterations, %0d call(s)", count, calls);
  end
endmodule
