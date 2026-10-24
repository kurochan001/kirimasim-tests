/*
:name: test_ipc_objects_created_per_call
:description: each call of an automatic task creates its own mailbox and semaphore at run time and uses them to synchronize with a process it spawns, and a new mailbox replaces the one a handle referred to (IEEE 1800-2023 Section 15.2)
:tags: ch15
:type: simulation
:lrm: 1800-2023 15.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_ipc_objects_created_per_call.expected
*/
// IEEE 1800-2023 §15.2: semaphores and mailboxes are objects that are created
// and reclaimed dynamically while the simulation runs, for synchronization and
// communication between processes.
// Each call of the automatic task relay creates a mailbox with the bound 1 and
// a semaphore without keys, starts a producer process that puts 1 to n into
// the mailbox and then a key into the semaphore, and gets the n messages and
// the key itself. The calls with n = 3 and n = 4 return the sums 6 and 10 and
// an empty mailbox, so each call worked with a mailbox of its own. The handle
// h then refers to a mailbox that holds two messages and is set to a new
// mailbox, which holds none.
// Icarus Verilog 13.0 does not support mailboxes and semaphores.

module test_ipc_objects_created_per_call;
  task automatic relay(input int n, output int sum, output int left);
    mailbox #(int) m = new(1);
    semaphore done = new(0);
    sum = 0;
    fork
      begin
        for (int i = 1; i <= n; i++) m.put(i);
        done.put(1);
      end
    join_none
    repeat (n) begin
      int v;
      m.get(v);
      sum += v;
    end
    done.get(1);
    left = m.num();
  endtask

  int s, l;
  mailbox #(int) h;

  initial begin
    relay(3, s, l);
    $display("relay(3) sum=%0d left=%0d", s, l);
    relay(4, s, l);
    $display("relay(4) sum=%0d left=%0d", s, l);
    h = new(0);
    h.put(7);
    h.put(8);
    $display("h num=%0d", h.num());
    h = new(0);
    $display("new h num=%0d", h.num());
  end
endmodule
