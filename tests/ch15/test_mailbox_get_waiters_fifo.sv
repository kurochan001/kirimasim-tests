/*
:name: test_mailbox_get_waiters_fifo
:description: Processes that wait in get on an empty mailbox receive the messages in the order in which they started to wait (IEEE 1800-2023 Section 15.4.5)
:tags: ch15
:type: simulation
:lrm: 1800-2023 15.4.5 15.4.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_mailbox_get_waiters_fifo.expected
*/
// IEEE 1800-2023 §15.4.5: get waits while the mailbox is empty, and the queue
// of waiting processes is first-in first-out: the mailbox keeps the order in
// which they arrived. B, C and A start to wait at 1, 2 and 3. Each put
// (15.4.3) at 10, 20 and 30 stores one message, which goes to the process
// that has waited longest: B, then C, then A, whatever their names or the
// order of the branches of the fork.

`timescale 1ns/1ns

module test_mailbox_get_waiters_fifo;
  mailbox #(string) m = new();
  string log = "";

  task automatic receive(string name, int delay);
    string s;
    #delay;
    m.get(s);
    log = {log, $sformatf(" %s:%s@%0d", name, s, $time)};
  endtask

  initial begin
    fork
      receive("A", 3);
      receive("B", 1);
      receive("C", 2);
    join_none
    #10 m.put("first");
    #10 m.put("second");
    #10 m.put("third");
    #1 $display("received:%s", log);
  end
endmodule
