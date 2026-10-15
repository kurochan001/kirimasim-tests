/*
:name: test_callback_chain
:description: Several user-written callbacks called in order through base-class handles
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.20 7.10
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_callback_chain.expected
*/
// A user-written callback pattern built from classes: virtual methods
// (8.20), a queue of base-class handles (7.10) and static members (8.10).
// This test verifies multiple callbacks in execution chain

module test_callback_chain;

  // Callback base class
  class callback_base;
    bit m_enabled;
    string m_name;

    function new(string name = "callback");
      m_name = name;
      m_enabled = 1;
    endfunction

    virtual function void on_execute();
    endfunction

    function bit is_enabled();
      return m_enabled;
    endfunction
  endclass

  // Callback with unique ID and counter
  class order_callback extends callback_base;
    int id;
    int call_count;

    function new(string name = "order_callback", int cb_id = 0);
      super.new(name);
      id = cb_id;
      call_count = 0;
    endfunction

    virtual function void on_execute();
      call_count++;
      $display("CALLBACK: id=%0d executing, count=%0d", id, call_count);
    endfunction
  endclass

  // Callback container
  class callback_container;
    callback_base m_callbacks[$];

    function void add(callback_base cb);
      if (cb != null) begin
        m_callbacks.push_back(cb);
      end
    endfunction

    function int size();
      return m_callbacks.size();
    endfunction

    function callback_base get(int idx);
      if (idx >= 0 && idx < m_callbacks.size()) begin
        return m_callbacks[idx];
      end
      return null;
    endfunction
  endclass

  // Component that executes callbacks
  class my_component;
    callback_container cb_container;

    function new();
      cb_container = new();
    endfunction

    function void add_callback(callback_base cb);
      cb_container.add(cb);
    endfunction

    function void do_operation();
      int i;
      int cb_size;
      callback_base cb;

      $display("COMPONENT: Executing operation");
      cb_size = cb_container.size();
      i = 0;
      while (i < cb_size) begin
        cb = cb_container.get(i);
        if (cb != null && cb.is_enabled()) begin
          cb.on_execute();
        end
        i = i + 1;
      end
      $display("COMPONENT: Operation done");
    endfunction
  endclass

  my_component comp;
  order_callback cb1, cb2, cb3;
  int test_pass;

  initial begin
    test_pass = 1;
    $display("=== Starting Callback Chain Test ===");

    // Create component
    comp = new();

    // Create callbacks with IDs
    cb1 = new("callback_1", 1);
    cb2 = new("callback_2", 2);
    cb3 = new("callback_3", 3);

    // Add callbacks in order
    comp.add_callback(cb1);
    comp.add_callback(cb2);
    comp.add_callback(cb3);
    $display("Registered 3 callbacks");

    // Execute operation
    $display("\n--- Test 1: Execute all callbacks ---");
    comp.do_operation();

    // Verify all were called once
    if (cb1.call_count == 1 && cb2.call_count == 1 && cb3.call_count == 1) begin
      $display("PASS: All callbacks called once");
    end else begin
      $display("FAIL: Expected all counts=1, got %0d,%0d,%0d",
               cb1.call_count, cb2.call_count, cb3.call_count);
      test_pass = 0;
    end

    // Execute again
    $display("\n--- Test 2: Execute again ---");
    comp.do_operation();

    // Verify counts incremented
    if (cb1.call_count == 2 && cb2.call_count == 2 && cb3.call_count == 2) begin
      $display("PASS: All callbacks called twice total");
    end else begin
      $display("FAIL: Expected all counts=2, got %0d,%0d,%0d",
               cb1.call_count, cb2.call_count, cb3.call_count);
      test_pass = 0;
    end

    // Report results
    $display("\n=== Test Complete ===");
    if (test_pass) begin
      $display("TEST PASSED");
    end else begin
      $display("TEST FAILED");
    end

    $finish;
  end
endmodule
