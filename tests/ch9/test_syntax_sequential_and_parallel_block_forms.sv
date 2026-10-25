/*
:name: test_syntax_sequential_and_parallel_block_forms
:description: Named and unnamed sequential blocks with declarations and null statements, and parallel blocks that end with join, join_any or join_none and carry labels, order their statements as A.6.3 says (IEEE 1800-2023 Section 9.3, A.6.3)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.3 9.3.1 9.3.2 9.3.3 A.6.3 A.6.4
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_syntax_sequential_and_parallel_block_forms.expected
*/
// IEEE 1800-2023 A.6.3: a sequential block is "begin [: label]" with block
// item declarations, then statements or null statements, then "end
// [: label]"; a parallel block is the same with fork and join, join_any or
// join_none. §9.3.1: a sequential block runs its statements in order after
// its declarations. §9.3.2: the branches of a parallel block start together,
// join waits for all of them, join_any for the first, and join_none for none.
//
// The first block declares a variable and increments it through a plain and
// a named nested block, with a null statement between. The next three blocks
// fork branches that log at 1, 3, 6 and 7. join logs both of its branches
// before "joined"; join_any logs only its first branch before "anydone" and
// leaves the other running; join_none logs "nonedone" at once, before its
// branch logs at 7. The labels after begin and after each join are used and
// a branch of the first fork declares a variable.
//
// The two branches that finish at different times make the log fixed; no two
// statements are logged at the same time except the branch and the join that
// waits for it, which is ordered by the join.

`timescale 1ns/1ns

module test_syntax_sequential_and_parallel_block_forms;
  string log = "";

  task automatic add(string s);
    log = {log, s, " "};
  endtask

  initial begin
    begin : seq_outer
      int a;
      a = 1;
      begin
        a = a + 2;
        ;
      end
      begin : seq_inner
        a++;
      end : seq_inner
      add($sformatf("seq=%0d", a));
    end : seq_outer

    fork : par_all
      int b;
      begin b = 1; #3 add("all3"); end
      begin #1 add("all1"); end
    join : par_all
    add("joined");

    fork : par_any
      begin #3 add("any3"); end
      begin #1 add("any1"); end
    join_any : par_any
    add("anydone");

    fork : par_none
      begin #3 add("none3"); end
    join_none : par_none
    add("nonedone");

    #10;
    $display("log: %s", log);
  end
endmodule
