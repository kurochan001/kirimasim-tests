/*
:name: test_mailbox_get_peek_task_ref_destination
:description: mailbox get() and peek() are tasks that wait for a message and pass their destination by reference, so a queue or dynamic array element whose array is replaced or resized while they wait does not receive the message (IEEE 1800-2023 Sections 15.4.5 and 15.4.7)
:tags: ch15
:type: simulation
:lrm: 1800-2023 15.4.5 15.4.7 13.5.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_mailbox_get_peek_task_ref_destination.expected
*/
// IEEE 1800-2023 §15.4.5 and §15.4.7: get() and peek() are tasks whose
// only argument, the destination of the message, is a ref argument; on an
// empty mailbox they block until a message is put. §13.5.2: an element of a
// queue or dynamic array passed by reference becomes an outdated reference
// when the queue is assigned or the array is resized with new[]; what the
// subroutine then writes through it is not visible in the array. A copy
// back on return, as for an output argument, would write the new array.
//
// Each case starts get() or peek() on an empty mailbox with an element as
// destination, in a process of its own, and puts the message later. When
// the array is left alone, the element receives the message. When the
// queue is assigned, or the dynamic array resized, before the message
// comes, the array keeps its new contents. peek() leaves the message in
// the mailbox (num=1) and get() removes it (num=0).
// Neither simulator runs this test: Icarus Verilog 13.0 does not support
// mailboxes, and release 5.052 of the Verilator tool rejects a queue or
// dynamic array element as a ref argument. The expected output follows the
// cited clauses.
`timescale 1ns/1ns

module test_mailbox_get_peek_task_ref_destination;
  mailbox #(int) mb = new;
  int q[$];
  int d[];
  int done_at, x;

  initial begin
    q = '{1, 2, 3};
    done_at = -1;
    fork
      begin
        mb.get(q[1]);
        done_at = $time;
      end
    join_none
    #2 mb.put(42);
    #1 $display("get(q[1]), q kept: returned at t=%0d q=%0d %0d %0d num=%0d",
                done_at, q[0], q[1], q[2], mb.num());

    q = '{1, 2, 3};
    done_at = -1;
    fork
      begin
        mb.get(q[1]);
        done_at = $time;
      end
    join_none
    #1 q = '{7, 8, 9};
    #1 mb.put(43);
    #1 $display("get(q[1]), q assigned: returned at t=%0d q=%0d %0d %0d num=%0d",
                done_at, q[0], q[1], q[2], mb.num());

    d = '{1, 2, 3};
    done_at = -1;
    fork
      begin
        mb.peek(d[2]);
        done_at = $time;
      end
    join_none
    #2 mb.put(55);
    #1 $display("peek(d[2]), d kept: returned at t=%0d d=%0d %0d %0d num=%0d",
                done_at, d[0], d[1], d[2], mb.num());
    mb.get(x);

    d = '{1, 2, 3};
    done_at = -1;
    fork
      begin
        mb.peek(d[2]);
        done_at = $time;
      end
    join_none
    #1 d = new[5](d);
    #1 mb.put(56);
    #1 $display("peek(d[2]), d resized: returned at t=%0d d=%0d %0d %0d %0d %0d num=%0d",
                done_at, d[0], d[1], d[2], d[3], d[4], mb.num());
  end
endmodule
