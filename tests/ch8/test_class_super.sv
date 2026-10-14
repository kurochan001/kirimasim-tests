/*
:name: test_class_super
:description: Test: super keyword usage
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.15 8.20 8.13
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_super.expected
*/
// Test: super keyword usage
// IEEE 1800-2023 Section 8.15 - Super

module test_class_super;

  // Base class
  class Base;
    int value;
    string name;

    function new(int v, string n);
      value = v;
      name = n;
    endfunction

    virtual function int compute();
      return value;
    endfunction

    virtual function string describe();
      return $sformatf("Base: %s = %0d", name, value);
    endfunction

    virtual function void reset();
      value = 0;
    endfunction
  endclass

  // Derived class using super
  class Derived extends Base;
    int multiplier;

    function new(int v, string n, int m);
      super.new(v, n);  // Call base constructor
      multiplier = m;
    endfunction

    virtual function int compute();
      // Use super to call base method and extend
      return super.compute() * multiplier;
    endfunction

    virtual function string describe();
      // Combine base description with derived info
      return $sformatf("%s (x%0d)", super.describe(), multiplier);
    endfunction

    virtual function void reset();
      super.reset();  // Reset base class
      multiplier = 1; // Reset derived
    endfunction
  endclass

  // Multi-level inheritance with super
  class DoubleDerived extends Derived;
    int offset;

    function new(int v, string n, int m, int o);
      super.new(v, n, m);  // Calls Derived::new
      offset = o;
    endfunction

    virtual function int compute();
      // super refers to immediate parent (Derived)
      return super.compute() + offset;
    endfunction

    virtual function string describe();
      return $sformatf("%s + %0d", super.describe(), offset);
    endfunction
  endclass

  // Class with super in task
  class Worker extends Base;
    int work_done;

    function new(string n);
      super.new(0, n);
      work_done = 0;
    endfunction

    virtual task do_work(int amount);
      work_done += amount;
      value = work_done;
    endtask

    virtual function void reset();
      super.reset();
      work_done = 0;
    endfunction
  endclass

  class FastWorker extends Worker;
    function new(string n);
      super.new(n);
    endfunction

    virtual task do_work(int amount);
      // Call parent task and do extra
      super.do_work(amount);
      work_done += amount;  // Double work
      value = work_done;
    endtask
  endclass

  initial begin
    Base b;
    Derived d;
    DoubleDerived dd;
    FastWorker fw;
    static int pass_count = 0;
    static int fail_count = 0;

    // Test 1: super.new() in constructor
    d = new(10, "test", 3);
    if (d.value == 10 && d.name == "test" && d.multiplier == 3) begin
      $display("PASS: Test 1 - super.new() initializes base class");
      pass_count++;
    end else begin
      $display("FAIL: Test 1 - super.new() failed");
      fail_count++;
    end

    // Test 2: super.method() in virtual function
    if (d.compute() == 30) begin
      $display("PASS: Test 2 - super.compute() extends base computation");
      pass_count++;
    end else begin
      $display("FAIL: Test 2 - super.compute() failed, got %0d", d.compute());
      fail_count++;
    end

    // Test 3: super.method() for string concatenation
    if (d.describe() == "Base: test = 10 (x3)") begin
      $display("PASS: Test 3 - super.describe() combines descriptions");
      pass_count++;
    end else begin
      $display("FAIL: Test 3 - super.describe() failed: %s", d.describe());
      fail_count++;
    end

    // Test 4: Multi-level super chaining
    dd = new(5, "multi", 2, 100);
    // compute: ((5) * 2) + 100 = 110
    if (dd.compute() == 110) begin
      $display("PASS: Test 4 - Multi-level super chaining works");
      pass_count++;
    end else begin
      $display("FAIL: Test 4 - Multi-level failed, got %0d", dd.compute());
      fail_count++;
    end

    // Test 5: super in task
    fw = new("worker1");
    fw.do_work(5);
    // FastWorker does double work: 5 + 5 = 10
    if (fw.work_done == 10) begin
      $display("PASS: Test 5 - super.do_work() in task works");
      pass_count++;
    end else begin
      $display("FAIL: Test 5 - super in task failed, got %0d", fw.work_done);
      fail_count++;
    end

    // Summary
    $display("\n=== Summary: %0d PASS, %0d FAIL ===", pass_count, fail_count);
    if (fail_count == 0)
      $display("PASS: All super keyword tests passed");
    else
      $display("FAIL: Some tests failed");

    $finish;
  end

endmodule
