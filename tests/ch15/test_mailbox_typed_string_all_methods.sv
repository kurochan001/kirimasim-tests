/*
:name: test_mailbox_typed_string_all_methods
:description: a mailbox specialized to string provides new, num, put, try_put, get, try_get, peek and try_peek, each behaving as the clause of the method describes, including the bound, blocking and the 0 results on a full or empty mailbox (IEEE 1800-2023 Section 15.4.9)
:tags: ch15
:type: simulation
:lrm: 1800-2023 15.4.9 15.4.1 15.4.2 15.4.3 15.4.4 15.4.5 15.4.6 15.4.7 15.4.8
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_mailbox_typed_string_all_methods.expected
*/
// IEEE 1800-2023 §15.4.9: a mailbox specialized to a message type provides
// the same methods as the typeless mailbox: new, num, put, try_put, get,
// try_get, peek and try_peek (§15.4.1 to §15.4.8).
//
// sm is a mailbox #(string) made with the bound 1. On the empty mailbox
// num is 0 and try_get and try_peek return 0 and leave s alone. try_put
// stores "a" and a second try_put returns 0 as the mailbox is full;
// try_peek and peek copy "a" and leave it there, try_get removes it. A
// get on the empty mailbox waits for the put of "late" at t=2. A put into
// the full mailbox waits for the get of another process at t=5. A peek on
// the empty mailbox waits for the put of "x" at t=9 and leaves it there.
`timescale 1ns/1ns

module test_mailbox_typed_string_all_methods;
  typedef mailbox #(string) s_mbox;
  s_mbox sm;
  string s, p, g;
  int r;

  initial begin
    sm = new(1);
    s = "unset";
    $display("empty: num=%0d", sm.num());
    r = sm.try_get(s);
    $display("empty: try_get=%0d s=%s", r, s);
    r = sm.try_peek(s);
    $display("empty: try_peek=%0d s=%s", r, s);
    r = sm.try_put("a");
    $display("try_put(\"a\"): positive=%0d num=%0d", r > 0, sm.num());
    r = sm.try_put("b");
    $display("full: try_put(\"b\")=%0d num=%0d", r, sm.num());
    r = sm.try_peek(s);
    $display("try_peek: positive=%0d s=%s num=%0d", r > 0, s, sm.num());
    s = "";
    sm.peek(s);
    $display("peek: s=%s num=%0d", s, sm.num());
    s = "";
    r = sm.try_get(s);
    $display("try_get: positive=%0d s=%s num=%0d", r > 0, s, sm.num());

    fork
      #2 sm.put("late");
    join_none
    sm.get(s);
    $display("t=%0d: get -> %s num=%0d", $time, s, sm.num());

    sm.put("full");
    fork
      #3 sm.get(g);
    join_none
    sm.put("next");
    $display("t=%0d: put(\"next\") returned; other process got %s, num=%0d", $time, g,
             sm.num());
    sm.get(s);

    fork
      #4 sm.put("x");
    join_none
    sm.peek(p);
    $display("t=%0d: peek -> %s num=%0d", $time, p, sm.num());
  end
endmodule
