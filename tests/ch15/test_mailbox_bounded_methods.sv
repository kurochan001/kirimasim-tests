/*
:name: test_mailbox_bounded_methods
:description: The non-blocking mailbox methods num, try_put, try_get and try_peek, and peek, on a bounded mailbox (IEEE 1800-2023 Section 15.4)
:tags: ch15
:type: simulation
:lrm: 1800-2023 15.4 15.4.1 15.4.2 15.4.4 15.4.6 15.4.7 15.4.8
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_mailbox_bounded_methods.expected
*/
// IEEE 1800-2023 §15.4.1: new(n) makes a mailbox that holds at most n
// messages. §15.4.2: num() is the number of messages in it. §15.4.4: try_put
// returns 0 when the mailbox is full and a positive value when it stores the
// message. §15.4.6, §15.4.8: try_get and try_peek return 0 when it is empty and
// a positive value otherwise; get and try_get remove the oldest message, while
// peek (15.4.7) and try_peek copy it and leave it in place.

module test_mailbox_bounded_methods;
  mailbox #(int) m;
  int v, r;

  initial begin
    m = new(2);
    m.put(1);
    m.put(2);
    r = m.try_put(3);
    $display("full: try_put=%0d num=%0d", r, m.num());
    m.peek(v);
    $display("peek=%0d num=%0d", v, m.num());
    m.get(v);
    $display("get=%0d num=%0d", v, m.num());
    r = m.try_peek(v);
    $display("try_peek ok=%0d v=%0d num=%0d", r > 0, v, m.num());
    r = m.try_get(v);
    $display("try_get ok=%0d v=%0d num=%0d", r > 0, v, m.num());
    v = 0;
    r = m.try_get(v);
    $display("empty: try_get=%0d v=%0d", r, v);
    r = m.try_peek(v);
    $display("empty: try_peek=%0d", r);
    r = m.try_put(4);
    $display("not full: try_put ok=%0d num=%0d", r > 0, m.num());
  end
endmodule
