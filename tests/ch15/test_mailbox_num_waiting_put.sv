/*
:name: test_mailbox_num_waiting_put
:description: num() of a full bounded mailbox does not count the message of a put that waits for room, the waiting put stores it when a get makes room, and a try_put that fails stores nothing (IEEE 1800-2023 Section 15.4.2)
:tags: ch15
:type: simulation
:lrm: 1800-2023 15.4.2 15.4.3 15.4.4 15.4.5 15.4.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_mailbox_num_waiting_put.expected
*/
// IEEE 1800-2023 §15.4.2: num() is the number of messages the mailbox holds
// at the moment. The mailbox holds at most 2 (15.4.1); a third put waits
// while it is full (15.4.3), so its message is not in the mailbox and num()
// stays 2. §15.4.4: try_put on the full mailbox returns 0 and does not store
// its message, now or later. The get at 5 removes the oldest message
// (15.4.5); the waiting put then goes on in the same time step, so at 6 the
// mailbox holds 2 and 3 again, and once they are taken it is empty: the 4
// of the failed try_put never arrives.

`timescale 1ns/1ns

module test_mailbox_num_waiting_put;
  mailbox #(int) m = new(2);
  int v, w, r;
  int put_done = -1;

  initial begin
    m.put(1);
    m.put(2);
    fork
      begin
        m.put(3);           // waits: the mailbox is full
        put_done = $time;
      end
    join_none
    #1 $display("t=1: num=%0d, the waiting put has ended: %0d", m.num(), put_done >= 0);
    r = m.try_put(4);
    $display("t=1: try_put on the full mailbox=%0d, num=%0d", r, m.num());
    #4 m.get(v);            // 5
    $display("t=5: get=%0d", v);
    #1 $display("t=6: num=%0d, the waiting put ended at %0d", m.num(), put_done);
    m.get(v);
    m.get(w);
    $display("t=6: get=%0d then %0d", v, w);
    r = m.try_get(v);
    $display("t=6: try_get on the emptied mailbox=%0d, num=%0d", r, m.num());
  end
endmodule
