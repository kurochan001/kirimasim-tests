/*
:name: test_mailbox_bounded_full_unbounded_never_full
:description: a mailbox with bound 2 holds two messages; a put to it then waits for room and a try_put returns 0 without adding its message, while mailboxes made with new() or new(0) take every put and try_put at once (IEEE 1800-2023 Sections 15.4 and 15.4.4)
:tags: ch15
:type: simulation
:lrm: 1800-2023 15.4 15.4.4 15.4.1 15.4.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_mailbox_bounded_full_unbounded_never_full.expected
*/
// IEEE 1800-2023 §15.4: a bounded mailbox is full when it holds its bound
// of messages, and a process that puts a message into a full mailbox is
// suspended until there is room; an unbounded mailbox never suspends a put.
// §15.4.4: try_put() into a full mailbox returns 0 and does not store the
// message; it returns a positive value when there is room, and an unbounded
// mailbox is never full. §15.4.1: new() and new(0) make unbounded mailboxes.
//
// b2 has the bound 2. After two puts it holds 2 messages; try_put(30)
// returns 0 and the count stays 2. A put(40) from another process is still
// blocked at t=3; the get at t=3 makes room, the put returns at t=3, and
// the mailbox then holds 20 and 40 only (30 was never stored). The two
// unbounded mailboxes take 10000 messages each at t=0.
`timescale 1ns/1ns

module test_mailbox_bounded_full_unbounded_never_full;
  mailbox #(int) b2, u_def, u_zero;
  int v, r, ok;
  int put40_at = -1;

  initial begin
    b2 = new(2);
    b2.put(10);
    b2.put(20);
    $display("bound 2: put(10), put(20) returned at t=%0d, num=%0d", $time, b2.num());
    r = b2.try_put(30);
    $display("full: try_put(30)=%0d num=%0d", r, b2.num());
    fork
      begin
        b2.put(40);
        put40_at = $time;
      end
    join_none
    #3 $display("t=%0d: put(40) returned=%0d num=%0d", $time, put40_at >= 0, b2.num());
    b2.get(v);
    $display("t=%0d: get -> %0d", $time, v);
    #1 $display("t=%0d: put(40) returned at t=%0d, num=%0d", $time, put40_at, b2.num());
    b2.get(v);
    $display("get -> %0d", v);
    b2.get(v);
    $display("get -> %0d", v);
    r = b2.try_get(v);
    $display("then try_get=%0d num=%0d", r, b2.num());
    r = b2.try_put(50);
    $display("try_put(50) with room: positive=%0d num=%0d", r > 0, b2.num());

    u_def = new;
    u_zero = new(0);
    ok = 0;
    for (int i = 0; i < 10000; i++) ok += (u_def.try_put(i) > 0);
    $display("new: positive try_puts=%0d of 10000, num=%0d", ok, u_def.num());
    for (int i = 0; i < 10000; i++) u_zero.put(i);
    $display("new(0): 10000 puts returned at t=%0d, num=%0d", $time, u_zero.num());
  end
endmodule
