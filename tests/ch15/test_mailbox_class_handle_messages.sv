/*
:name: test_mailbox_class_handle_messages
:description: A mailbox parameterized with a class type passes object handles, not copies of the objects, including a null handle, through put, try_put, peek, get and try_get (IEEE 1800-2023 Section 15.4.3)
:tags: ch15
:type: simulation
:lrm: 1800-2023 15.4.3 15.4.4 15.4.9 15.4.5 15.4.7 15.4.6
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_mailbox_class_handle_messages.expected
*/
// IEEE 1800-2023 §15.4.3, §15.4.4: the message of put and try_put can be any
// singular expression, object handles among them. §15.4.9: a mailbox type can
// be parameterized with the type of its messages, here a class, through a
// typedef. A handle is the message: what get, peek and try_get return
// (15.4.5, 15.4.7, 15.4.6) is the same handle, so a change made to the object
// after the put is seen through the handle taken out, and a change made
// through that handle is seen through the first one. A null handle is a
// message like any other. Messages come out in the order they were put.

class mailbox_item;
  int val;
  function new(int v);
    val = v;
  endfunction
endclass

typedef mailbox #(mailbox_item) item_box;

module test_mailbox_class_handle_messages;
  item_box box = new(3);
  mailbox_item a, b, got, seen;
  int r;

  initial begin
    a = new(1);
    b = new(2);
    box.put(a);
    r = box.try_put(b);
    box.put(null);
    $display("try_put stored b: %0d, num=%0d", r > 0, box.num());
    a.val = 10;
    box.peek(seen);
    box.get(got);
    $display("get gave a: %0d, val=%0d, peek gave the same handle: %0d", got == a, got.val,
             seen == got);
    got.val = 11;
    $display("a.val=%0d", a.val);
    b.val = 20;
    r = box.try_get(got);
    $display("try_get ok=%0d, gave b: %0d, val=%0d", r > 0, got == b, got.val);
    got = a;
    box.get(got);
    $display("the third message is null: %0d, num=%0d", got == null, box.num());
  end
endmodule
