/*
:name: test_ref_static_fork_join_none_after_return
:description: a process spawned by fork-join_none can read and write a ref static argument after the task has returned, reaching the caller's variable as it is then, while a plain ref argument may be used there only to initialize a variable of the fork block (IEEE 1800-2023 Sections 9.3.2, 13.5.2)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.3.2 13.5.2 6.21
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_ref_static_fork_join_none_after_return.expected
*/
// IEEE 1800-2023 §9.3.2: inside fork-join_any or fork-join_none, a formal
// argument passed by reference may be used only in the initialization of a
// variable declared in the fork block, unless it is declared ref static.
// §13.5.2: a ref static argument is passed only variables of static
// lifetime, so the reference stays valid after the call returns, and the
// caller and the subroutine share the variable: a change made by either one
// is seen by the other at once.
// - spawn forks a process that waits one time unit, reads r into seen[id]
//   and adds n to r. Both calls return at time 0, before the processes run,
//   so counter and other are still 0 and 100 when the initial process
//   prints them. The initial process then sets counter to 6, so at time 1
//   the first process sees 6 and makes counter 16, and the second sees 100
//   and makes other 101; they write different variables, so their order does
//   not matter.
// - snapshot has a plain ref argument, which its fork block may use only to
//   initialize the fork variable copy; that happens when the fork starts,
//   while counter is 5. The forked process stores copy in snap at time 3,
//   and the initial process prints it at time 4: 5.
// The expected output follows the standard alone: Icarus Verilog 13.0 does
// not support ref arguments, and the 5.052 release of Verilator does not
// support ref static ones.

module test_ref_static_fork_join_none_after_return;
  int counter;
  int other;
  int seen[2];
  int snap;

  task automatic spawn(ref static int r, input int id, input int n);
    fork
      begin
        #1 seen[id] = r;
        r = r + n;
      end
    join_none
  endtask

  task automatic snapshot(ref int p);
    fork
      automatic int copy = p;
      #3 snap = copy;
    join_none
  endtask

  initial begin
    counter = 0;
    other = 100;
    spawn(counter, 0, 10);
    spawn(other, 1, 1);
    $display("returned: counter=%0d other=%0d", counter, other);
    counter = 5;
    snapshot(counter);
    counter = 6;
    #2;
    $display("t=2: seen=%0d,%0d counter=%0d other=%0d", seen[0], seen[1], counter, other);
    #2;
    $display("t=4: snap=%0d", snap);
  end
endmodule
