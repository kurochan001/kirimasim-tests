/*
:name: test_mailbox_blocking_put_get
:description: put blocks while a bounded mailbox is full and get blocks while it is empty, in FIFO order, for a parameterized and an unbounded mailbox (IEEE 1800-2023 Section 15.4.3)
:tags: ch15
:type: simulation
:lrm: 1800-2023 15.4.3 15.4.5 15.4.9 15.4.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_mailbox_blocking_put_get.expected
*/
// IEEE 1800-2023 §15.4.3: put stores a message in FIFO order and, when a
// bounded mailbox is full, waits until there is room. §15.4.5: get removes the
// oldest message and waits while the mailbox is empty. §15.4.9: a mailbox can
// be parameterized with the type of its messages. §15.4.1: new() with no bound
// makes an unbounded mailbox, which is never full.

`timescale 1ns/1ns

module test_mailbox_blocking_put_get;
  mailbox #(string) box;
  mailbox #(int) unb;
  string s1, s2;
  int t_second_put, t_first_get, t_second_get, t_waited;
  int x, n_ok;

  initial begin
    box = new(1);
    fork
      begin
        box.put("a");
        box.put("b");            // waits until the first get makes room
        t_second_put = $time;
      end
      begin
        #5 box.get(s1);
        t_first_get = $time;
        #5 box.get(s2);
        t_second_get = $time;
      end
    join
    $display("second put done at %0d, gets at %0d and %0d", t_second_put, t_first_get, t_second_get);
    $display("received %s then %s", s1, s2);

    fork
      begin box.get(s1); t_waited = $time; end   // waits on the empty mailbox
      #4 box.put("late");
    join
    $display("get on empty mailbox returned at %0d with %s", t_waited, s1);

    unb = new();
    n_ok = 0;
    repeat (50) if (unb.try_put(7) > 0) n_ok++;
    $display("unbounded: %0d of 50 try_put succeeded, num=%0d", n_ok, unb.num());
  end
endmodule
