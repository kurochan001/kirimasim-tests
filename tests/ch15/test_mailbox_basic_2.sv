/*
:name: test_mailbox_basic_2
:description: Mailbox put, get and try_get, and a bounded mailbox with try_put
:tags: ch15
:type: simulation
:lrm: 1800-2023 15.4
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_mailbox_basic_2.expected
*/
// IEEE 1800-2023 §15.4 Mailboxes
// Test basic mailbox operations

module test_mailbox_basic_2;
  mailbox #(int) mb;

  initial begin
    // Create unbounded mailbox
    mb = new();

    // Put data into mailbox
    mb.put(42);
    mb.put(100);
    $display("Put 42 and 100 into mailbox");

    // Get data from mailbox
    begin
      int data;
      mb.get(data);
      assert(data == 42) else $fatal(1, "Expected 42, got %0d", data);
      $display("Got %0d from mailbox", data);

      mb.get(data);
      assert(data == 100) else $fatal(1, "Expected 100, got %0d", data);
      $display("Got %0d from mailbox", data);
    end

    // Test try_get on empty mailbox
    begin
      int data;
      if (mb.try_get(data))
        $fatal(1, "try_get should fail on empty mailbox");
      else
        $display("try_get correctly failed on empty mailbox");
    end

    // Test bounded mailbox
    mb = new(2);  // Mailbox with size 2
    mb.put(10);
    mb.put(20);
    $display("Put 10 and 20 into bounded mailbox (size=2)");

    // Try to put third item (should block, but we test with try_put)
    if (!mb.try_put(30))
      $display("try_put correctly failed on full mailbox");
    else
      $fatal(1, "try_put should fail on full mailbox");

    // Get one item, then put should succeed
    begin
      int data;
      mb.get(data);
      $display("Got %0d, mailbox has space now", data);
    end

    mb.put(30);
    $display("Successfully put 30 after freeing space");

    $display("PASS: Mailbox test completed");
    $finish;
  end
endmodule
