/*
:name: test_ref_and_inout_object_handle_replacement
:description: Through a ref formal of class type a task can change both the object and the caller's handle itself, which the caller sees at once, while a new object assigned to an inout handle formal reaches the caller only when the task returns (IEEE 1800-2023 Section 13.5.2)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.5.2 13.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_ref_and_inout_object_handle_replacement.expected
*/
// IEEE 1800-2023 §13.5.2: object handles passed as ref or inout arguments
// follow the usual rules: a ref of a handle lets the subroutine change the
// handle itself (assign a new object) as well as the contents of the
// object, and the caller sees the change at once; an inout handle is copied
// in at the call and copied back at the return (13.3).
//
// Each task first sets v of the object it was given, then after 2 assigns a
// new object to its formal, and returns at 4. The caller looks at v of its
// own handle at 1 (after the first change), at 3 (after the new object was
// assigned) and after the return. With ref it sees 11, then the new object
// 22; with inout it sees 33, still 33 (the old object), and 44 only after
// the return.

`timescale 1ns/1ns

module test_ref_and_inout_object_handle_replacement;
  class Box;
    int v;
    function new(int x);
      v = x;
    endfunction
  endclass

  Box h;

  task automatic by_ref(ref Box b);
    b.v = 11;
    #2 b = new(22);
    #2;
  endtask

  task automatic by_inout(inout Box b);
    b.v = 33;
    #2 b = new(44);
    #2;
  endtask

  initial begin
    h = new(1);
    fork
      by_ref(h);
      begin
        #1 $display("ref:   t=%0t h.v=%0d", $time, h.v);
        #2 $display("ref:   t=%0t h.v=%0d", $time, h.v);
      end
    join
    $display("ref:   after return h.v=%0d", h.v);

    h = new(2);
    fork
      by_inout(h);
      begin
        #1 $display("inout: t=%0t h.v=%0d", $time, h.v);
        #2 $display("inout: t=%0t h.v=%0d", $time, h.v);
      end
    join
    $display("inout: after return h.v=%0d", h.v);
  end
endmodule
