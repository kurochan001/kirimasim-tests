/*
:name: test_foreach_index_shadows_outer
:description: A foreach loop variable named like an outer variable leaves the outer variable unchanged (IEEE 1800-2023 Section 12.7.3)
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.7.3 6.8 9.4.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_foreach_index_shadows_outer.expected
*/
// IEEE 1800-2023 §12.7.3: a foreach loop declares its loop variables in an
// implicit block of its own, with automatic lifetime. A loop variable with the
// same name as a task variable or a module variable hides it inside the loop and
// is a different variable, so the outer one keeps its value whether or not the
// loop body waits and however the loop ends, and a process waiting on the outer
// variable is not woken (9.4.2).
//
// The module variables get their initial values before any procedure starts
// (6.8), so @(gi) sees no change at time 0 either. Verilator 5.052 counts one
// wakeup of @(gi) here.

module test_foreach_index_shadows_outer;
  int gi = 777;      // module variable hidden by a loop that waits
  int gj = 555;      // module variable hidden by a loop that does not wait
  int ev_count = 0;  // wakeups of @(gi); must stay 0
  int fails = 0;

  always @(gi) ev_count++;

  // loop without waits, task variable of the same name
  task automatic t_sync_local;
    int arr[3] = '{1, 2, 3};
    int i = 444;
    int acc = 0;
    foreach (arr[i]) acc += arr[i];
    if (acc == 6 && i == 444) $display("A1 ok");
    else begin fails++; $display("A1 bad acc=%0d i=%0d", acc, i); end
  endtask

  // the same, leaving the loop with break
  task automatic t_sync_local_break;
    int arr[3] = '{1, 2, 3};
    int i = 444;
    int acc = 0;
    foreach (arr[i]) begin
      acc += arr[i];
      if (arr[i] == 2) break;
    end
    if (acc == 3 && i == 444) $display("A2 ok");
    else begin fails++; $display("A2 bad acc=%0d i=%0d", acc, i); end
  endtask

  // loop without waits, module variable of the same name
  task automatic t_sync_modscope;
    int arr[3] = '{1, 2, 3};
    int acc = 0;
    foreach (arr[gj]) acc += arr[gj];
    if (acc == 6 && gj == 555) $display("A3 ok");
    else begin fails++; $display("A3 bad acc=%0d gj=%0d", acc, gj); end
  endtask

  // loop that waits, task variable of the same name
  task automatic t_timed_local;
    int arr[3] = '{1, 2, 3};
    int i = 999;
    int acc = 0;
    foreach (arr[i]) begin
      #1;
      acc += arr[i];
    end
    if (acc == 6 && i == 999) $display("B1 ok");
    else begin fails++; $display("B1 bad acc=%0d i=%0d", acc, i); end
  endtask

  // loop that waits, module variable of the same name
  task automatic t_timed_modscope;
    int arr[3] = '{1, 1, 1};
    int acc = 0;
    foreach (arr[gi]) begin
      #1;
      acc += arr[gi];
    end
    if (acc == 3 && gi == 777) $display("B2 ok");
    else begin fails++; $display("B2 bad acc=%0d gi=%0d", acc, gi); end
  endtask

  // the same, leaving the loop with break
  task automatic t_timed_modscope_break;
    int arr[3] = '{1, 2, 3};
    int acc = 0;
    foreach (arr[gi]) begin
      #1;
      acc += arr[gi];
      if (arr[gi] == 2) break;
    end
    if (acc == 3 && gi == 777) $display("B3 ok");
    else begin fails++; $display("B3 bad acc=%0d gi=%0d", acc, gi); end
  endtask

  // control: a loop variable with a new name
  task automatic t_plain;
    int arr[4] = '{5, 6, 7, 8};
    int acc = 0;
    foreach (arr[k]) acc += arr[k];
    if (acc == 26) $display("C1 ok");
    else begin fails++; $display("C1 bad acc=%0d", acc); end
  endtask

  initial begin
    t_sync_local();
    t_sync_local_break();
    t_sync_modscope();
    t_timed_local();
    t_timed_modscope();
    t_timed_modscope_break();
    t_plain();
    #1;
    if (ev_count != 0) begin fails++; $display("EV bad ev_count=%0d", ev_count); end
    if (gi != 777 || gj != 555) begin
      fails++;
      $display("FINAL bad gi=%0d gj=%0d", gi, gj);
    end
    if (fails == 0) $display("TEST PASSED");
    else $display("TEST FAILED fails=%0d", fails);
    $finish;
  end
endmodule
