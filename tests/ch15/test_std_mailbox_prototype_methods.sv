/*
:name: test_std_mailbox_prototype_methods
:description: A std::mailbox of a given type has the methods of its Annex G prototype: new with a bound defaulting to 0 (unbounded), num, try_put, try_get and try_peek int functions, put a task that waits for room, and get and peek tasks that wait for a message, the last four writing to their argument by reference (IEEE 1800-2023 Section 15.4, G.4)
:tags: ch15
:type: simulation
:lrm: 1800-2023 15.4 G.4 15.4.1 15.4.2 15.4.3 15.4.4 15.4.5 15.4.6 15.4.7 15.4.8 15.4.9
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_std_mailbox_prototype_methods.expected
*/
// IEEE 1800-2023 G.4 gives the prototype of the mailbox class of the std
// package, with the message type as its type parameter T: new(int bound = 0),
// the int functions num, try_put(T), try_get(ref T) and try_peek(ref T), and
// the tasks put(T), get(ref T) and peek(ref T). §15.4.1: a bound of 0 makes
// the mailbox unbounded. §15.4.2 to §15.4.8: num gives the number of
// messages; put waits while a bounded mailbox is full, try_put returns 0
// then and a positive integer when it stores the message; get and peek wait
// while the mailbox is empty, try_get and try_peek return 0 then; get and
// try_get take the oldest message, peek and try_peek copy it.
//
// The mailboxes are std::mailbox #(byte). A default new takes 100 messages
// with try_put, while new(2) refuses the third. A put on the full mailbox
// returns only at time 5, when try_get makes room; a get and a peek on empty
// mailboxes return only at times 10 and 11, when a message is put in each.
// The message arguments of get, try_get, peek and try_peek are by reference:
// a try_get or try_peek on an empty mailbox leaves the variable at 55, where
// an output argument would be copied back. The function fn_ops calls try_put,
// try_peek, try_get and num, which a function may do only for functions
// (13.4), and $typename, which does not evaluate its argument (20.6.1), gives
// their result types. Only whether a try_ result is positive is printed, since
// its value is not fixed. Each call is a statement of its own, and each
// process prints at a time when no other process acts on its mailbox. Icarus
// Verilog 13.0 does not know the std::mailbox type.

`timescale 1ns/1ns

module test_std_mailbox_prototype_methods;
  std::mailbox #(byte) m_def, m_two, m_get, m_peek, m_fn;
  byte v, g, p;
  int n, r1, r2, r3;

  function automatic int fn_ops(std::mailbox #(byte) m);
    byte x = 0;
    int a, b, c;
    a = m.try_put(8'sd12);
    b = m.try_peek(x);
    c = m.try_get(x);
    return (a > 0) + (b > 0) + (c > 0) + m.num() + x;
  endfunction

  initial begin
    m_def = new;
    n = 0;
    for (int i = 0; i < 100; i++)
      if (m_def.try_put(byte'(i)) > 0) n++;
    $display("new(): %0d of 100 try_put stored, num %0d", n, m_def.num());
    m_two = new(2);
    r1 = m_two.try_put(8'sd1);
    r2 = m_two.try_put(8'sd2);
    r3 = m_two.try_put(8'sd3);
    $display("new(2): try_put>0 %0d %0d %0d, num %0d", r1 > 0, r2 > 0, r3 > 0, m_two.num());
    fork
      begin
        m_two.put(8'sd4);
        $display("%0t: put returned, num %0d", $time, m_two.num());
      end
    join_none
    #5 r1 = m_two.try_get(v);
    #1 $display("%0t: try_get>0 %0d got %0d, num %0d", $time, r1 > 0, v, m_two.num());
    m_get = new;
    m_peek = new;
    fork
      begin
        m_get.get(g);
        $display("%0t: get returned %0d, num %0d", $time, g, m_get.num());
      end
      begin
        m_peek.peek(p);
        $display("%0t: peek returned %0d, num %0d", $time, p, m_peek.num());
      end
    join_none
    #4 m_get.put(-8'sd7);
    #1 m_peek.put(8'sd70);
    #1 v = 55;
    r1 = m_get.try_get(v);
    r2 = m_get.try_peek(v);
    $display("%0t: empty: try_get %0d, try_peek %0d, variable %0d", $time, r1, r2, v);
    r1 = m_peek.try_peek(v);
    $display("try_peek>0 %0d copied %0d, num %0d", r1 > 0, v, m_peek.num());
    v = 0;
    r1 = m_two.try_get(v);
    r2 = m_two.try_get(g);
    r3 = m_two.try_get(p);
    $display("FIFO: %0d %0d, then try_get %0d, num %0d", v, g, r3, m_two.num());
    m_fn = new;
    $display("fn_ops: %0d", fn_ops(m_fn));
    $display("result types: num %s, try_put %s, try_get %s, try_peek %s",
             $typename(m_fn.num()), $typename(m_fn.try_put(v)), $typename(m_fn.try_get(v)),
             $typename(m_fn.try_peek(v)));
  end
endmodule
