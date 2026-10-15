/*
:name: test_builtin_methods_mixed
:description: Built-in methods of queues, dynamic arrays, associative arrays and strings
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.10 7.5 7.9 6.16
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_builtin_methods_mixed.expected
*/

module test_builtin_methods_mixed;
  int pass_count = 0;
  int test_count = 0;

  // ========== Queue Tests ==========
  int q[$];
  int q_result;

  // ========== Dynamic Array Tests ==========
  int dyn[];
  int d_result;
  int dmin[$];
  int dmax[$];

  // ========== Associative Array Tests ==========
  int assoc[int];  // Use int keys for simpler testing
  int a_exists;
  int a_key;
  int a_found;

  // ========== String Tests ==========
  string str;
  string str_result;
  int s_result;

  initial begin
    // ==================== QUEUE METHODS ====================
    $display("=== Testing Queue Methods ===");

    // Test 1: Queue size
    q = {};
    test_count++;
    if (q.size() == 0) begin
      $display("PASS: queue.size() empty = 0");
      pass_count++;
    end else begin
      $display("FAIL: queue.size() empty");
    end

    // Test 2: push_back
    q.push_back(10);
    q.push_back(20);
    q.push_back(30);
    test_count++;
    if (q.size() == 3) begin
      $display("PASS: queue.push_back 3 elements");
      pass_count++;
    end else begin
      $display("FAIL: queue.push_back size = %0d", q.size());
    end

    // Test 3: push_front
    q.push_front(5);
    test_count++;
    if (q.size() == 4 && q[0] == 5) begin
      $display("PASS: queue.push_front");
      pass_count++;
    end else begin
      $display("FAIL: queue.push_front");
    end

    // Test 4: pop_back
    q_result = q.pop_back();
    test_count++;
    if (q_result == 30 && q.size() == 3) begin
      $display("PASS: queue.pop_back = %0d", q_result);
      pass_count++;
    end else begin
      $display("FAIL: queue.pop_back = %0d", q_result);
    end

    // Test 5: pop_front
    q_result = q.pop_front();
    test_count++;
    if (q_result == 5 && q.size() == 2) begin
      $display("PASS: queue.pop_front = %0d", q_result);
      pass_count++;
    end else begin
      $display("FAIL: queue.pop_front = %0d", q_result);
    end

    // Test 6: delete
    q.delete();
    test_count++;
    if (q.size() == 0) begin
      $display("PASS: queue.delete");
      pass_count++;
    end else begin
      $display("FAIL: queue.delete");
    end

    // ==================== DYNAMIC ARRAY METHODS ====================
    $display("");
    $display("=== Testing Dynamic Array Methods ===");

    // Test 7: new
    dyn = new[5];
    test_count++;
    if (dyn.size() == 5) begin
      $display("PASS: dynamic_array.new(5)");
      pass_count++;
    end else begin
      $display("FAIL: dynamic_array.new size = %0d", dyn.size());
    end

    // Test 8: Initialize and test size
    foreach (dyn[i]) dyn[i] = (i + 1) * 10;
    test_count++;
    if (dyn.size() == 5) begin
      $display("PASS: dynamic_array.size() = 5");
      pass_count++;
    end else begin
      $display("FAIL: dynamic_array.size()");
    end

    // Test 9: delete
    dyn.delete();
    test_count++;
    if (dyn.size() == 0) begin
      $display("PASS: dynamic_array.delete()");
      pass_count++;
    end else begin
      $display("FAIL: dynamic_array.delete()");
    end

    // Test 10: Dynamic array sum
    dyn = new[4];
    dyn[0] = 10;
    dyn[1] = 30;
    dyn[2] = 20;
    dyn[3] = 40;
    d_result = dyn.sum();
    test_count++;
    if (d_result == 100) begin
      $display("PASS: dynamic_array.sum() = %0d", d_result);
      pass_count++;
    end else begin
      $display("FAIL: dynamic_array.sum() = %0d", d_result);
    end

    // Test 11: Dynamic array min (returns queue)
    dmin = dyn.min();
    test_count++;
    if (dmin.size() > 0 && dmin[0] == 10) begin
      $display("PASS: dynamic_array.min()[0] = %0d", dmin[0]);
      pass_count++;
    end else begin
      $display("FAIL: dynamic_array.min()");
    end

    // Test 12: Dynamic array max (returns queue)
    dmax = dyn.max();
    test_count++;
    if (dmax.size() > 0 && dmax[0] == 40) begin
      $display("PASS: dynamic_array.max()[0] = %0d", dmax[0]);
      pass_count++;
    end else begin
      $display("FAIL: dynamic_array.max()");
    end

    // ==================== ASSOCIATIVE ARRAY METHODS ====================
    $display("");
    $display("=== Testing Associative Array Methods ===");

    // Test 13: exists
    assoc[1] = 100;
    assoc[2] = 200;
    a_exists = assoc.exists(1);
    test_count++;
    if (a_exists == 1) begin
      $display("PASS: assoc.exists(1) = 1");
      pass_count++;
    end else begin
      $display("FAIL: assoc.exists(1) = %0d", a_exists);
    end

    a_exists = assoc.exists(99);
    test_count++;
    if (a_exists == 0) begin
      $display("PASS: assoc.exists(99) = 0");
      pass_count++;
    end else begin
      $display("FAIL: assoc.exists(99) = %0d", a_exists);
    end

    // Test 15: num/size
    test_count++;
    if (assoc.num() == 2) begin
      $display("PASS: assoc.num() = 2");
      pass_count++;
    end else begin
      $display("FAIL: assoc.num() = %0d", assoc.num());
    end

    // Test 16: first
    a_found = assoc.first(a_key);
    test_count++;
    if (a_found) begin
      $display("PASS: assoc.first() found key = %0d", a_key);
      pass_count++;
    end else begin
      $display("FAIL: assoc.first() not found");
    end

    // Test 17: delete specific key
    assoc.delete(1);
    test_count++;
    if (assoc.num() == 1 && assoc.exists(1) == 0) begin
      $display("PASS: assoc.delete(1)");
      pass_count++;
    end else begin
      $display("FAIL: assoc.delete(1)");
    end

    // ==================== STRING METHODS ====================
    $display("");
    $display("=== Testing String Methods ===");

    // Test 18: len
    str = "Hello World";
    test_count++;
    if (str.len() == 11) begin
      $display("PASS: string.len() = 11");
      pass_count++;
    end else begin
      $display("FAIL: string.len() = %0d", str.len());
    end

    // Test 19: toupper
    str_result = str.toupper();
    test_count++;
    if (str_result == "HELLO WORLD") begin
      $display("PASS: string.toupper()");
      pass_count++;
    end else begin
      $display("FAIL: string.toupper() = '%s'", str_result);
    end

    // Test 20: tolower
    str_result = str.tolower();
    test_count++;
    if (str_result == "hello world") begin
      $display("PASS: string.tolower()");
      pass_count++;
    end else begin
      $display("FAIL: string.tolower() = '%s'", str_result);
    end

    // Test 21: substr (IEEE 1800-2023: inclusive end index)
    str_result = str.substr(0, 4);
    test_count++;
    if (str_result == "Hello") begin
      $display("PASS: string.substr(0,4) = '%s'", str_result);
      pass_count++;
    end else begin
      $display("FAIL: string.substr(0,4) = '%s'", str_result);
    end

    // Test 22: getc
    s_result = str.getc(0);
    test_count++;
    if (s_result == 72) begin  // 'H' = ASCII 72
      $display("PASS: string.getc(0) = %0d (H)", s_result);
      pass_count++;
    end else begin
      $display("FAIL: string.getc(0) = %0d", s_result);
    end

    // Test 23: compare
    str = "ABC";
    s_result = str.compare("ABC");
    test_count++;
    if (s_result == 0) begin
      $display("PASS: string.compare(equal) = 0");
      pass_count++;
    end else begin
      $display("FAIL: string.compare(equal) = %0d", s_result);
    end

    s_result = str.compare("ABD");
    test_count++;
    if (s_result < 0) begin
      $display("PASS: string.compare(less) < 0");
      pass_count++;
    end else begin
      $display("FAIL: string.compare(less) = %0d", s_result);
    end

    // Test 25: atoi
    str = "12345";
    s_result = str.atoi();
    test_count++;
    if (s_result == 12345) begin
      $display("PASS: string.atoi() = %0d", s_result);
      pass_count++;
    end else begin
      $display("FAIL: string.atoi() = %0d", s_result);
    end

    // Test 26: atohex
    str = "FF";
    s_result = str.atohex();
    test_count++;
    if (s_result == 255) begin
      $display("PASS: string.atohex() = %0d", s_result);
      pass_count++;
    end else begin
      $display("FAIL: string.atohex() = %0d", s_result);
    end

    // Summary
    $display("");
    $display("=== Built-in Method Test Summary ===");
    $display("Tests passed: %0d/%0d", pass_count, test_count);

    if (pass_count == test_count) begin
      $display("TEST PASSED");
    end else begin
      $display("TEST FAILED");
    end

    $finish;
  end
endmodule
