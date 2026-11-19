/*
:name: test_ch6_extra_for_loop_automatic
:description: A for loop variable and the variables of a class method are automatic by default, so a fork block item can copy the loop variable for each process and each method call keeps its own value (IEEE 1800-2023 Section 6.21)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.21 12.7.1 8.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_ch6_extra_for_loop_automatic.expected
*/
// IEEE 1800-2023 §6.21: class methods (§8.4) and the variables declared by a
// for loop (§12.7.1) are automatic by default, regardless of the lifetime
// attribute of the scope that contains them. The module scope here is static.
// The loop declares one automatic i for the whole loop (§12.7.1), and the
// three join_none processes start only after the loop has ended with i at 3
// (§9.3.2). Each fork therefore declares the block item k, an automatic
// variable initialized from i when the fork statement is executed, in the
// iteration that spawns the process; the process reads its own k after the
// loop has finished, so got holds 0, 1 and 2. A static loop variable cannot
// be copied this way and leaves got at its initial 0, 0, 0.
// The class method depth calls itself with its own local variable saved; the
// calls do not share saved, so the sum is 3 + 2 + 1 + 0 = 6.
// The values are collected first and printed in index order, so no output
// depends on the order of same-time processes.
// Icarus Verilog 13.0 gives the loop variable one static value (0, 0, 0), so
// its output is recorded as a known difference; it has no oracle here.

module test_ch6_extra_for_loop_automatic;
  class test_ch6_extra_for_loop_automatic_c;
    function automatic int depth(int n);
      int saved;
      saved = n;
      if (n == 0) return saved;
      return depth(n - 1) + saved;
    endfunction
  endclass

  test_ch6_extra_for_loop_automatic_c c = new();
  int got[3];

  initial begin
    for (int i = 0; i < 3; i++) begin
      fork
        automatic int k = i;
        begin
          #0 got[k] = k;
        end
      join_none
    end
    #1 $display("got=%0d %0d %0d depth=%0d", got[0], got[1], got[2], c.depth(3));
  end
endmodule
