/*
:name: test_task_storage_per_call_and_per_instance
:description: Overlapping calls of an automatic task get their own variables, overlapping calls of a static task in one module instance share them, and the static task of another instance of the module has variables of its own (IEEE 1800-2023 Section 13.3.2)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.3.2 13.3.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_task_storage_per_call_and_per_instance.expected
*/
// IEEE 1800-2023 §13.3.2: all variables of an automatic task are replicated
// for each concurrent call. A static task has a single copy of each local
// variable per module instance, whatever the number of concurrent calls,
// but the static tasks of different instances of a module have separate
// storage.
//
// The module keeper has a static task st and an automatic task at; each
// stores its input in a local variable, waits 3 and returns the local
// variable. Two calls of the same task of one instance start at times 0
// and 1; two calls of st in two different instances start at 10 and 11.
// The second call of st in the same instance overwrites the shared local
// variable, so both calls return 2; at returns 1 and 2; the calls in the
// two instances return 10 and 20.

`timescale 1ns/1ns

module keeper;
  task st(input int v, output int seen); // static: one copy per instance
    int keep;
    keep = v;
    #3 seen = keep;
  endtask

  task automatic at(input int v, output int seen);
    int keep;
    keep = v;
    #3 seen = keep;
  endtask
endmodule

module test_task_storage_per_call_and_per_instance;
  keeper k1 ();
  keeper k2 ();
  int s1, s2, a1, a2, i1, i2;

  initial begin
    fork
      k1.st(1, s1);
      #1 k1.st(2, s2);
    join
    $display("static task, same instance, calls at 0 and 1: %0d %0d", s1, s2);
    fork
      k1.at(1, a1);
      #1 k1.at(2, a2);
    join
    $display("automatic task, same instance, calls at 4 and 5: %0d %0d", a1, a2);
    #2;
    fork
      k1.st(10, i1);
      #1 k2.st(20, i2);
    join
    $display("static task, instances k1 and k2, calls at 10 and 11: %0d %0d", i1, i2);
  end
endmodule
