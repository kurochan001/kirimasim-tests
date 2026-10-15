/*
:name: test_class_static_2
:description: Test: static property, static method, shared state across instances
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.9 8.10
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_static_2.expected
*/
// Test: static property, static method, shared state across instances
module test_class_static_2;

  class Counter;
    static int count = 0;
    int id;

    function new();
      count++;
      id = count;
    endfunction

    static function int get_count();
      return count;
    endfunction

    static function void reset();
      count = 0;
    endfunction
  endclass

  initial begin
    static int pass_cnt = 0;
    static int fail_cnt = 0;
    Counter c1, c2, c3;

    // Check 1: initial static count
    if (Counter::get_count() == 0) begin pass_cnt++; $display("PASS: initial count == 0"); end
    else begin fail_cnt++; $display("FAIL: initial count = %0d", Counter::get_count()); end

    // Check 2: after first instance
    c1 = new();
    if (Counter::get_count() == 1) begin pass_cnt++; $display("PASS: count == 1 after c1"); end
    else begin fail_cnt++; $display("FAIL: count = %0d", Counter::get_count()); end

    // Check 3: instance id
    if (c1.id == 1) begin pass_cnt++; $display("PASS: c1.id == 1"); end
    else begin fail_cnt++; $display("FAIL: c1.id = %0d", c1.id); end

    // Check 4: count shared across instances
    c2 = new();
    c3 = new();
    if (Counter::get_count() == 3) begin pass_cnt++; $display("PASS: count == 3 after 3 instances"); end
    else begin fail_cnt++; $display("FAIL: count = %0d", Counter::get_count()); end

    // Check 5: each instance has unique id
    if (c2.id == 2 && c3.id == 3) begin pass_cnt++; $display("PASS: unique ids c2=2 c3=3"); end
    else begin fail_cnt++; $display("FAIL: c2.id=%0d c3.id=%0d", c2.id, c3.id); end

    // Check 6: static method via instance also works
    if (c1.get_count() == 3) begin pass_cnt++; $display("PASS: static method via instance"); end
    else begin fail_cnt++; $display("FAIL: c1.get_count() = %0d", c1.get_count()); end

    // Check 7: reset static state
    Counter::reset();
    if (Counter::get_count() == 0) begin pass_cnt++; $display("PASS: count == 0 after reset"); end
    else begin fail_cnt++; $display("FAIL: count = %0d after reset", Counter::get_count()); end

    $display("Results: %0d passed, %0d failed", pass_cnt, fail_cnt);
    if (fail_cnt == 0) $display("TEST PASSED"); else $display("TEST FAILED");
    $finish;
  end

endmodule
