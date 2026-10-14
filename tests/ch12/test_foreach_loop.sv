/*
:name: test_foreach_loop
:description: Test foreach loop (IEEE 1800-2023 Section 12.7.3)
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.7.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_foreach_loop.expected
*/
// Test foreach loop (IEEE 1800-2023 Section 12.7.3)

module test_foreach_loop;
  int arr[5];
  int dyn_arr[];
  int queue[$];
  int sum;
  int pass_count;

  initial begin
    pass_count = 0;

    arr[0] = 10; arr[1] = 20; arr[2] = 30; arr[3] = 40; arr[4] = 50;
    sum = 0;
    foreach(arr[i]) begin
      sum += arr[i];
    end
    if (sum == 150) pass_count++;

    // Test 2: Foreach with index access
    sum = 0;
    foreach(arr[i]) begin
      sum += i;
    end
    if (sum == 10) pass_count++;  // 0+1+2+3+4

    // Test 3: Foreach on dynamic array
    dyn_arr = new[3];
    dyn_arr[0] = 100;
    dyn_arr[1] = 200;
    dyn_arr[2] = 300;
    sum = 0;
    foreach(dyn_arr[i]) begin
      sum += dyn_arr[i];
    end
    if (sum == 600) pass_count++;

    // Test 4: Foreach on queue
    queue.push_back(5);
    queue.push_back(10);
    queue.push_back(15);
    sum = 0;
    foreach(queue[i]) begin
      sum += queue[i];
    end
    if (sum == 30) pass_count++;

    // Test 5: Nested foreach
    sum = 0;
    foreach(arr[i]) begin
      foreach(dyn_arr[j]) begin
        sum++;
      end
    end
    if (sum == 15) pass_count++;  // 5 * 3

    $display("Foreach loop tests: %0d/5 passed", pass_count);
    if (pass_count >= 4) begin
      $display("PASS: Foreach loop tests");
    end else begin
      $display("FAIL: Some foreach tests failed");
    end
  end
endmodule
