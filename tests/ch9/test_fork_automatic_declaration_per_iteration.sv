/*
:name: test_fork_automatic_declaration_per_iteration
:description: An automatic variable declared in a fork block gets the loop's value of that iteration in each spawned process, in for, while and do-while loops (IEEE 1800-2023 Section 9.3.2)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.3.2 6.21
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_fork_automatic_declaration_per_iteration.expected
*/
// IEEE 1800-2023 §9.3.2: the declarations of a fork block are initialized
// each time the fork is executed, before its processes start, and an
// automatic one (6.21) is a new variable for each execution. So in a loop
// that runs fork automatic int k = i; ... join_none, each spawned process
// keeps the value i had in its own iteration, even though it reads k after i
// has moved on.

module test_fork_automatic_declaration_per_iteration;
  int got_for[$], got_while[$], got_do[$];

  initial begin
    int i;
    for (i = 0; i < 3; i++) begin
      fork
        automatic int k = i;
        #1 got_for.push_back(k);
      join_none
    end
    i = 10;
    while (i < 13) begin
      fork
        automatic int k = i;
        #2 got_while.push_back(k);
      join_none
      i++;
    end
    i = 20;
    do begin
      fork
        automatic int k = i;
        #3 got_do.push_back(k);
      join_none
      i++;
    end while (i < 23);
    #5;
    got_for.sort();
    got_while.sort();
    got_do.sort();
    $display("for: %0d %0d %0d", got_for[0], got_for[1], got_for[2]);
    $display("while: %0d %0d %0d", got_while[0], got_while[1], got_while[2]);
    $display("do-while: %0d %0d %0d", got_do[0], got_do[1], got_do[2]);
  end
endmodule
