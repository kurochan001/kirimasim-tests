/*
:name: test_callback_enable_disable
:description: Enabling and disabling a user-written callback object
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.20 7.10
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_callback_enable_disable.expected
*/
// A user-written callback pattern built from classes: virtual methods
// (8.20), a queue of base-class handles (7.10) and static members (8.10).
// This test verifies callback enable/disable functionality

module test_callback_enable_disable;

  // Callback base class
  class callback_base;
    bit m_enabled;

    function new();
      m_enabled = 1;
    endfunction

    virtual function void on_event(int data);
    endfunction

    function bit is_enabled();
      return m_enabled;
    endfunction

    function void enable();
      m_enabled = 1;
    endfunction

    function void disable_cb();
      m_enabled = 0;
    endfunction

    function bit callback_mode(int on);
      if (on >= 0) begin
        m_enabled = (on != 0);
      end
      return m_enabled;
    endfunction
  endclass

  // Concrete callback
  class my_callback extends callback_base;
    int call_count;

    function new();
      super.new();
      call_count = 0;
    endfunction

    virtual function void on_event(int data);
      call_count++;
      $display("CALLBACK: on_event(data=%0d), count=%0d", data, call_count);
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

  // Component
  class my_component;
    callback_container cb_container;

    function new();
      cb_container = new();
    endfunction

    function void add_callback(callback_base cb);
      cb_container.add(cb);
    endfunction

    function void trigger_callbacks(int data);
      int i;
      int cb_size;
      callback_base cb;

      cb_size = cb_container.size();
      i = 0;
      while (i < cb_size) begin
        cb = cb_container.get(i);
        if (cb != null && cb.is_enabled()) begin
          cb.on_event(data);
        end
        i = i + 1;
      end
    endfunction
  endclass

  my_component comp;
  my_callback cb;
  int test_pass;

  initial begin
    test_pass = 1;
    $display("=== Starting Enable/Disable Test ===");

    // Create component and callback
    comp = new();
    cb = new();
    comp.add_callback(cb);

    // Test 1: Callback enabled (default)
    $display("\n--- Test 1: Callback enabled (default) ---");
    comp.trigger_callbacks(100);
    if (cb.call_count == 1) begin
      $display("PASS: Callback called");
    end else begin
      $display("FAIL: Expected count=1, got %0d", cb.call_count);
      test_pass = 0;
    end

    // Test 2: Disable callback using callback_mode(0)
    $display("\n--- Test 2: Disable using callback_mode(0) ---");
    cb.callback_mode(0);
    comp.trigger_callbacks(200);
    if (cb.call_count == 1) begin
      $display("PASS: Disabled callback not called");
    end else begin
      $display("FAIL: Disabled callback should not be called");
      test_pass = 0;
    end

    // Test 3: Re-enable using callback_mode(1)
    $display("\n--- Test 3: Enable using callback_mode(1) ---");
    cb.callback_mode(1);
    comp.trigger_callbacks(300);
    if (cb.call_count == 2) begin
      $display("PASS: Re-enabled callback called");
    end else begin
      $display("FAIL: Expected count=2, got %0d", cb.call_count);
      test_pass = 0;
    end

    // Test 4: Disable using disable_cb()
    $display("\n--- Test 4: Disable using disable_cb() ---");
    cb.disable_cb();
    comp.trigger_callbacks(400);
    if (cb.call_count == 2) begin
      $display("PASS: Disabled callback not called");
    end else begin
      $display("FAIL: Disabled callback should not be called");
      test_pass = 0;
    end

    // Test 5: Enable using enable()
    $display("\n--- Test 5: Enable using enable() ---");
    cb.enable();
    comp.trigger_callbacks(500);
    if (cb.call_count == 3) begin
      $display("PASS: Enabled callback called");
    end else begin
      $display("FAIL: Expected count=3, got %0d", cb.call_count);
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
