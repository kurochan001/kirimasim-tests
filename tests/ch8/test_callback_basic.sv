/*
:name: test_callback_basic
:description: A user-written callback pattern built from classes and virtual methods
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.20 8.10 7.10
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_callback_basic.expected
*/
// A user-written callback pattern built from classes: virtual methods
// (8.20), a queue of base-class handles (7.10) and static members (8.10).
// This test verifies basic callback registration and execution

module test_callback_basic;

  class callback_base;
    bit m_enabled;
    string m_name;

    function new(string name = "callback");
      m_name = name;
      m_enabled = 1;
    endfunction

    virtual function void on_pre_do(int data);
    endfunction

    virtual function void on_post_do(int data);
    endfunction

    function bit is_enabled();
      return m_enabled;
    endfunction

    function void callback_mode(bit enable);
      m_enabled = enable;
    endfunction
  endclass

  // Concrete callback with counters
  class my_callback extends callback_base;
    int pre_count;
    int post_count;

    function new(string name = "my_callback");
      super.new(name);
      pre_count = 0;
      post_count = 0;
    endfunction

    virtual function void on_pre_do(int data);
      pre_count++;
      $display("CALLBACK: on_pre_do(data=%0d), pre_count=%0d", data, pre_count);
    endfunction

    virtual function void on_post_do(int data);
      post_count++;
      $display("CALLBACK: on_post_do(data=%0d), post_count=%0d", data, post_count);
    endfunction
  endclass

  // Callback container using queue
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

  // Driver with callback support
  class my_driver;
    string name;
    int items_processed;
    static callback_container cb_container;

    function new(string n = "driver");
      name = n;
      items_processed = 0;
      if (cb_container == null) begin
        cb_container = new();
      end
    endfunction

    static function void add_callback(callback_base cb);
      if (cb_container == null) begin
        cb_container = new();
      end
      cb_container.add(cb);
      $display("DRIVER: Added callback, total=%0d", cb_container.size());
    endfunction

    function void process_item(int data);
      int i;
      int cb_size;
      callback_base cb;

      $display("DRIVER: process_item(data=%0d)", data);

      // Execute pre_do callbacks
      cb_size = cb_container.size();
      i = 0;
      while (i < cb_size) begin
        cb = cb_container.get(i);
        if (cb != null && cb.is_enabled()) begin
          cb.on_pre_do(data);
        end
        i = i + 1;
      end

      // Process item
      items_processed++;
      $display("DRIVER: Processing item, total=%0d", items_processed);

      // Execute post_do callbacks
      i = 0;
      while (i < cb_size) begin
        cb = cb_container.get(i);
        if (cb != null && cb.is_enabled()) begin
          cb.on_post_do(data);
        end
        i = i + 1;
      end

      $display("DRIVER: process_item done");
    endfunction
  endclass

  my_driver drv;
  my_callback cb;
  int test_pass;

  initial begin
    test_pass = 1;
    $display("=== Starting Callback Basic Test ===");

    // Create driver
    drv = new("test_driver");
    $display("Created driver");

    // Create and register callback
    cb = new("test_cb");
    my_driver::add_callback(cb);

    // Test 1: Process with callback enabled
    $display("\n--- Test 1: Callback enabled ---");
    drv.process_item(100);
    if (cb.pre_count == 1 && cb.post_count == 1) begin
      $display("PASS: Callbacks called correctly");
    end else begin
      $display("FAIL: Expected pre=1,post=1 got pre=%0d,post=%0d", cb.pre_count, cb.post_count);
      test_pass = 0;
    end

    // Test 2: Process again
    $display("\n--- Test 2: Second process ---");
    drv.process_item(200);
    if (cb.pre_count == 2 && cb.post_count == 2) begin
      $display("PASS: Callbacks called correctly");
    end else begin
      $display("FAIL: Expected pre=2,post=2 got pre=%0d,post=%0d", cb.pre_count, cb.post_count);
      test_pass = 0;
    end

    // Test 3: Disable callback
    $display("\n--- Test 3: Callback disabled ---");
    cb.callback_mode(0);
    drv.process_item(300);
    if (cb.pre_count == 2 && cb.post_count == 2) begin
      $display("PASS: Disabled callback not called");
    end else begin
      $display("FAIL: Disabled callback should not be called");
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
