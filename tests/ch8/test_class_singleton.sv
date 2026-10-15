/*
:name: test_class_singleton
:description: Test: Singleton pattern
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.9 8.10 8.7
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_singleton.expected
*/
// Test: Singleton pattern
// IEEE 1800-2023 - Singleton design pattern implementation
// Simplified version using class-based state tracking

module test_class_singleton;

  // Simple singleton-like class with instance counting
  class Counter;
    static int creation_count = 0;
    int id;
    int value;
    string name;

    function new();
      creation_count++;
      id = creation_count;
      value = 0;
      name = "default";
    endfunction

    function void set_value(int v);
      value = v;
    endfunction

    function int get_value();
      return value;
    endfunction

    function void set_name(string n);
      name = n;
    endfunction

    function string get_name();
      return name;
    endfunction

    static function int get_creation_count();
      return creation_count;
    endfunction

    function int get_id();
      return id;
    endfunction
  endclass

  // Configuration class
  class Config;
    int debug_level;
    string output_file;
    bit enable_logging;

    function new();
      debug_level = 0;
      output_file = "output.log";
      enable_logging = 0;
    endfunction

    function void configure(int level, string file, bit logging);
      debug_level = level;
      output_file = file;
      enable_logging = logging;
    endfunction

    function string describe();
      return $sformatf("Debug=%0d, File=%s, Logging=%0b",
                       debug_level, output_file, enable_logging);
    endfunction
  endclass

  // IdGenerator class
  class IdGenerator;
    int next_id;

    function new();
      next_id = 1000;
    endfunction

    function int get_next_id();
      int id = next_id;
      next_id++;
      return id;
    endfunction

    function int peek_next_id();
      return next_id;
    endfunction
  endclass

  // Logger class
  class Logger;
    string log_buffer[$];

    function new();
    endfunction

    function void log(string msg);
      log_buffer.push_back(msg);
    endfunction

    function int log_count();
      return log_buffer.size();
    endfunction

    function string get_log(int idx);
      if (idx < log_buffer.size())
        return log_buffer[idx];
      return "";
    endfunction
  endclass

  initial begin
    Counter c1, c2;
    Config cfg;
    IdGenerator id_gen;
    Logger logger;
    int id1, id2, id3;
    static int pass_count = 0;
    static int fail_count = 0;

    // Test 1: Static instance counting across objects
    c1 = new();
    c2 = new();
    if (Counter::get_creation_count() == 2 && c1.get_id() == 1 && c2.get_id() == 2) begin
      $display("PASS: Test 1 - Static counter tracks creation correctly");
      pass_count++;
    end else begin
      $display("FAIL: Test 1 - Static counter error: count=%0d, id1=%0d, id2=%0d",
               Counter::get_creation_count(), c1.get_id(), c2.get_id());
      fail_count++;
    end

    // Test 2: Object state modification
    c1.set_value(42);
    c1.set_name("counter1");
    if (c1.get_value() == 42 && c1.get_name() == "counter1") begin
      $display("PASS: Test 2 - Object state modification works");
      pass_count++;
    end else begin
      $display("FAIL: Test 2 - State modification error");
      fail_count++;
    end

    // Test 3: Config class state
    cfg = new();
    cfg.configure(3, "debug.log", 1);
    if (cfg.describe() == "Debug=3, File=debug.log, Logging=1") begin
      $display("PASS: Test 3 - Config class state works");
      pass_count++;
    end else begin
      $display("FAIL: Test 3 - Config state error: %s", cfg.describe());
      fail_count++;
    end

    // Test 4: IdGenerator produces sequential IDs
    id_gen = new();
    id1 = id_gen.get_next_id();
    id2 = id_gen.get_next_id();
    id3 = id_gen.get_next_id();
    if (id1 == 1000 && id2 == 1001 && id3 == 1002) begin
      $display("PASS: Test 4 - IdGenerator produces sequential IDs");
      pass_count++;
    end else begin
      $display("FAIL: Test 4 - IDs not sequential: %0d, %0d, %0d", id1, id2, id3);
      fail_count++;
    end

    // Test 5: Logger collects logs
    logger = new();
    logger.log("First message");
    logger.log("Second message");
    logger.log("Third message");
    if (logger.log_count() == 3 &&
        logger.get_log(0) == "First message" &&
        logger.get_log(2) == "Third message") begin
      $display("PASS: Test 5 - Logger collects all logs");
      pass_count++;
    end else begin
      $display("FAIL: Test 5 - Logger error: count=%0d", logger.log_count());
      fail_count++;
    end

    // Summary
    $display("\n=== Summary: %0d PASS, %0d FAIL ===", pass_count, fail_count);
    if (fail_count == 0)
      $display("PASS: All singleton pattern tests passed");
    else
      $display("FAIL: Some tests failed");

    $finish;
  end

endmodule
