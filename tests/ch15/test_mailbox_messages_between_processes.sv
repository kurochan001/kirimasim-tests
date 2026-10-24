/*
:name: test_mailbox_messages_between_processes
:description: messages that one process puts into a mailbox, before or after the receiver starts waiting, are received by another process in the order they were put, and answers come back through a second mailbox (IEEE 1800-2023 Section 15.4)
:tags: ch15
:type: simulation
:lrm: 1800-2023 15.4 15.4.3 15.4.5
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_mailbox_messages_between_processes.expected
*/
// IEEE 1800-2023 §15.4: a mailbox lets processes exchange messages: data
// that one process sends to it is retrieved by another. §15.4.3: put()
// stores the messages in strict FIFO order. §15.4.5: get() removes one
// message, and blocks while the mailbox is empty.
//
// The sender puts 11, 22 and 33 at t=0, while the receiver only starts at
// t=5, so the messages wait in the mailbox; the receiver gets them at t=5
// in that order, then waits for 44, which the sender puts at t=8. For each
// message the receiver sends back ten times its value through a second
// mailbox. Each process records what it got and when, and prints the
// record after the exchange is over, so the output does not depend on how
// the two processes interleave within t=5.
`timescale 1ns/1ns

module test_mailbox_messages_between_processes;
  mailbox #(int) to_rx = new;
  mailbox #(int) to_tx = new;

  initial begin : sender
    int answer;
    string got;
    got = "";
    to_rx.put(11);
    to_rx.put(22);
    to_rx.put(33);
    repeat (3) begin
      to_tx.get(answer);
      got = {got, $sformatf(" %0d@%0d", answer, $time)};
    end
    #3 to_rx.put(44);
    to_tx.get(answer);
    got = {got, $sformatf(" %0d@%0d", answer, $time)};
    #1 $display("sender got answers:%s", got);
  end

  initial begin : receiver
    int v;
    string got;
    got = "";
    #5;
    repeat (4) begin
      to_rx.get(v);
      got = {got, $sformatf(" %0d@%0d", v, $time)};
      to_tx.put(v * 10);
    end
    #2 $display("receiver got:%s", got);
  end
endmodule
