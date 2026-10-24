/*
:name: test_vpi_tf_call_kinds_relations
:description: function calls, task calls and method function and task calls are tf calls with their scope and arguments; a call of a user subroutine leads to its task or function, a call of a built-in method to NULL; a method call gives the object it is applied to through vpiPrefix, vpiUserDefn tells user-defined methods from built-in ones, vpiWith gives the with expression of an array locator method and the inline constraint of randomize, vpiFuncType gives the result type of a function call, and vpi_get_value the value of a function or method function call (IEEE 1800-2023 Section 37.42)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.42 37.41 36.4 7.12.1 18.7 15.4 13.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_tf_call_kinds_relations.c
:expected_stdout: @test_vpi_tf_call_kinds_relations.expected
*/
// IEEE 1800-2023 §37.42: task call, function call, method function call and
// method task call make up the tf call group, so each has vpiScope, the scope
// it is in (here the named block blk), and vpiArgument. A function call leads
// to its function (vpiFunction) and a task call to its task (vpiTask), also
// in §37.41; a method call leads to the method of the class, and to NULL for
// a built-in method such as size, find and randomize of a queue or class, or
// put of a mailbox (detail 11, 7.12.1, 18.7, 15.4). vpiPrefix gives the
// object the method is applied to (detail 2), the class variable p, the queue
// q or the mailbox mb; vpiUserDefn is TRUE only for a method declared in a
// class. vpiWith is available for randomize and the array locator methods
// (detail 1): it gives the expression item > 1 of find with and the inline
// constraint of randomize with, while the call of get, which has no with
// clause, gives NULL. vpiFuncType of a function call is the type of the
// function's result (13.4): vpiSizedFunc for twice, an 8-bit vector, and
// vpiRealFunc for half. vpi_get_value gives the value of a function call or a
// method function call: twice(4) is 8, p.get() is 5 and q.size() is 3. The
// arguments of $vt_args are not evaluated when it is called (36.4), so
// randomize does not run. The task call statements are found among the
// statements of blk and printed sorted.

`timescale 1ns/1ns

module test_vpi_tf_call_kinds_relations;
  class pkt;
    int id;

    function int get();
      return id;
    endfunction

    task bump();
      id++;
    endtask
  endclass

  pkt p;
  int q[$];
  mailbox #(int) mb;

  function logic [7:0] twice(input int v);
    return 8'(2 * v);
  endfunction

  function real half(input real v);
    return v / 2.0;
  endfunction

  task note(input int v);
  endtask

  initial begin : blk
    p = new;
    p.id = 5;
    q = '{3, 1, 2};
    mb = new;
    #1 $vt_args(twice(4), half(3.0), p.get(), q.size(), q.find with (item > 1),
                p.randomize() with { id < 10; });
    note(7);
    p.bump();
    mb.put(1);
  end
endmodule
