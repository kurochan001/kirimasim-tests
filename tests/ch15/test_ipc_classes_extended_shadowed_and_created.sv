/*
:name: test_ipc_classes_extended_shadowed_and_created
:description: semaphore and mailbox are std classes that can be extended, created at run time and redeclared in another scope (IEEE 1800-2023 Section 15.2)
:tags: ch15
:type: simulation
:lrm: 1800-2023 15.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_ipc_classes_extended_shadowed_and_created.expected
*/
// IEEE 1800-2023 §15.2: semaphore and mailbox are built-in classes of the std
// package (26.7). Their objects are created and reclaimed dynamically, they can
// be used as base classes (8.13), and as they live in std, user code may
// declare the same names in any other scope.
// counted_sem extends semaphore and tagged_box extends mailbox #(int); the
// methods they add call the inherited get(), put() and try_get(), and a
// tagged_box handle is also used through a mailbox #(int) handle. The package
// user_ipc declares its own class mailbox, which its function make_local()
// creates by the plain name, while the module still reaches the built-in class
// as std::mailbox and as mailbox. Three mailboxes and two semaphores are made
// with new while the simulation runs. try_get() returns a positive integer on
// success (15.3.4, 15.4.6), so only r > 0 is printed.
// Icarus Verilog 13.0 does not support these classes.

package user_ipc;
  class mailbox;
    int marker = 7;
  endclass
  function automatic int make_local();
    mailbox m = new;
    return m.marker;
  endfunction
endpackage

module test_ipc_classes_extended_shadowed_and_created;
  class counted_sem extends semaphore;
    int taken;
    function new(int keys);
      super.new(keys);
    endfunction
    task take(int n);
      get(n);
      taken += n;
    endtask
  endclass

  class tagged_box extends mailbox #(int);
    string tag;
    function new(string t);
      super.new();
      tag = t;
    endfunction
    task send(int v);
      put(v);
    endtask
  endclass

  counted_sem cs;
  tagged_box tb;
  mailbox #(int) base_h;
  std::mailbox #(int) boxes[3];
  semaphore s;
  int v, r1, r2;

  initial begin
    cs = new(2);
    cs.take(2);
    r1 = cs.try_get(1);
    cs.put(1);
    r2 = cs.try_get(1);
    $display("counted_sem taken=%0d first=%0d second=%0d", cs.taken, r1 > 0, r2 > 0);

    tb = new("tb");
    tb.send(5);
    tb.send(6);
    $display("tagged_box %s num=%0d", tb.tag, tb.num());
    tb.get(v);
    base_h = tb;
    base_h.get(r1);
    $display("tagged_box got %0d then %0d num=%0d", v, r1, tb.num());

    foreach (boxes[i]) begin
      boxes[i] = new();
      boxes[i].put(10 * i + 1);
    end
    foreach (boxes[i]) begin
      boxes[i].get(v);
      $display("box %0d holds %0d", i, v);
    end

    s = new(1);
    s = new(3);
    r1 = s.try_get(3);
    $display("new semaphore keys taken=%0d", r1 > 0);

    $display("user mailbox marker=%0d", user_ipc::make_local());
  end
endmodule
