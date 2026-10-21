/*
:name: test_mailbox_peek_unblocks_all
:description: Processes that wait in peek on an empty mailbox are all released by one message, which they copy and leave in the mailbox (IEEE 1800-2023 Section 15.4.7)
:tags: ch15
:type: simulation
:lrm: 1800-2023 15.4.7 15.4.2 15.4.5
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_mailbox_peek_unblocks_all.expected
*/
// IEEE 1800-2023 §15.4.7: peek waits while the mailbox is empty and copies
// the oldest message without removing it, so one message can release several
// processes: every process waiting in peek goes on while the message stays.
// Three processes start to peek at 1, 2 and 3; the put at 10 releases all of
// them at 10 with the same message, and at 11 the mailbox still holds it
// (15.4.2), so a get (15.4.5) returns it and empties the mailbox.

`timescale 1ns/1ns

module test_mailbox_peek_unblocks_all;
  mailbox #(int) m = new();
  int seen[3] = '{-1, -1, -1};
  int at[3] = '{-1, -1, -1};
  int v;

  task automatic watch(int k);
    int x;
    #(k + 1);
    m.peek(x);
    seen[k] = x;
    at[k] = $time;
  endtask

  initial begin
    fork
      watch(0);
      watch(1);
      watch(2);
    join_none
    #10 m.put(42);
    #1 $display("t=11: the peeks gave %0d %0d %0d at %0d %0d %0d, num=%0d", seen[0], seen[1],
                seen[2], at[0], at[1], at[2], m.num());
    m.get(v);
    $display("t=11: get=%0d, num=%0d", v, m.num());
  end
endmodule
