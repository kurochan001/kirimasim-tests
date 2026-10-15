/*
:name: test_semaphore_basic
:description: Test semaphore (IEEE 1800-2023 Section 15.3)
:tags: ch15
:type: simulation
:lrm: 1800-2023 15.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_semaphore_basic.expected
*/
// Test semaphore (IEEE 1800-2023 Section 15.3)

module test_semaphore_basic;
  semaphore sem;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Create semaphore with 2 keys
    sem = new(2);
    if (sem != null) pass_count++;

    // Test 2: Get one key
    sem.get(1);
    pass_count++;

    // Test 3: Get another key
    sem.get(1);
    pass_count++;

    // Test 4: Put keys back
    sem.put(1);
    pass_count++;

    // Test 5: Try get
    if (sem.try_get(1)) pass_count++;

    $display("Semaphore basic tests: %0d/5 passed", pass_count);
    if (pass_count == 5) begin
      $display("PASS: Semaphore basic tests");
    end else begin
      $display("FAIL: Some semaphore tests failed");
    end
  end
endmodule
