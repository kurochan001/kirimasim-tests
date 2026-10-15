/*
:name: test_memory_edge_cases
:description: Memory and array edge cases: initialization, bounds, dynamic arrays, queues and associative arrays
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.4 7.5 7.8 7.10
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_memory_edge_cases.expected
*/
// Memory and array edge cases: initialization, bounds, dynamic arrays, queues and associative arrays

module test_memory_edge_cases;
    int pass_count = 0;
    int fail_count = 0;

    // Static arrays
    logic [7:0] mem_8x8 [0:7];
    logic [15:0] mem_16x4 [0:3];

    // Dynamic arrays
    int dyn_arr[];
    string str_arr[];

    // Queues
    int q[$];
    string sq[$];

    // Associative arrays
    int assoc[string];
    string str_assoc[int];

    initial begin
        $display("=== Memory Edge Cases Test ===");

        // Test static array initialization
        $display("\n--- Static Array Init ---");
        for (int i = 0; i < 8; i++) begin
            mem_8x8[i] = i * 10;
        end
        if (mem_8x8[0] == 0 && mem_8x8[7] == 70) begin
            $display("PASS: static array init");
            pass_count++;
        end else begin
            $display("FAIL: static array init");
            fail_count++;
        end

        // Test static array boundary
        $display("\n--- Static Array Boundary ---");
        mem_8x8[0] = 8'hFF;
        mem_8x8[7] = 8'hAA;
        if (mem_8x8[0] == 8'hFF && mem_8x8[7] == 8'hAA) begin
            $display("PASS: static array boundary");
            pass_count++;
        end else begin
            $display("FAIL: static array boundary");
            fail_count++;
        end

        // Test dynamic array creation
        $display("\n--- Dynamic Array Create ---");
        dyn_arr = new[5];
        if (dyn_arr.size() == 5) begin
            $display("PASS: dynamic array create");
            pass_count++;
        end else begin
            $display("FAIL: dynamic array size = %0d", dyn_arr.size());
            fail_count++;
        end

        // Test dynamic array resize
        $display("\n--- Dynamic Array Resize ---");
        dyn_arr = new[10](dyn_arr);
        if (dyn_arr.size() == 10) begin
            $display("PASS: dynamic array resize");
            pass_count++;
        end else begin
            $display("FAIL: dynamic array size = %0d", dyn_arr.size());
            fail_count++;
        end

        // Test dynamic array delete
        $display("\n--- Dynamic Array Delete ---");
        dyn_arr.delete();
        if (dyn_arr.size() == 0) begin
            $display("PASS: dynamic array delete");
            pass_count++;
        end else begin
            $display("FAIL: dynamic array size = %0d", dyn_arr.size());
            fail_count++;
        end

        // Test queue push operations
        $display("\n--- Queue Push ---");
        q.push_back(10);
        q.push_back(20);
        q.push_front(5);
        if (q.size() == 3 && q[0] == 5 && q[2] == 20) begin
            $display("PASS: queue push");
            pass_count++;
        end else begin
            $display("FAIL: queue push");
            fail_count++;
        end

        // Test queue pop operations
        $display("\n--- Queue Pop ---");
        q.pop_front();
        q.pop_back();
        if (q.size() == 1 && q[0] == 10) begin
            $display("PASS: queue pop");
            pass_count++;
        end else begin
            $display("FAIL: queue pop size=%0d", q.size());
            fail_count++;
        end

        // Test queue insert
        $display("\n--- Queue Insert ---");
        q.delete();
        q.push_back(1);
        q.push_back(3);
        q.insert(1, 2);
        if (q[0] == 1 && q[1] == 2 && q[2] == 3) begin
            $display("PASS: queue insert");
            pass_count++;
        end else begin
            $display("FAIL: queue insert");
            fail_count++;
        end

        // Test associative array basic
        $display("\n--- Associative Array Basic ---");
        assoc["one"] = 1;
        assoc["two"] = 2;
        assoc["three"] = 3;
        if (assoc["one"] == 1 && assoc["two"] == 2) begin
            $display("PASS: associative array basic");
            pass_count++;
        end else begin
            $display("FAIL: associative array basic");
            fail_count++;
        end

        // Test associative array exists
        $display("\n--- Associative Array Exists ---");
        if (assoc.exists("one") && !assoc.exists("four")) begin
            $display("PASS: associative array exists");
            pass_count++;
        end else begin
            $display("FAIL: associative array exists");
            fail_count++;
        end

        // Test associative array delete key
        $display("\n--- Associative Array Delete Key ---");
        assoc.delete("one");
        if (!assoc.exists("one") && assoc.exists("two")) begin
            $display("PASS: associative array delete key");
            pass_count++;
        end else begin
            $display("FAIL: associative array delete key");
            fail_count++;
        end

        // Test associative array size
        $display("\n--- Associative Array Size ---");
        if (assoc.num() == 2) begin
            $display("PASS: associative array size = %0d", assoc.num());
            pass_count++;
        end else begin
            $display("FAIL: associative array size = %0d", assoc.num());
            fail_count++;
        end

        // Test string array
        $display("\n--- String Array ---");
        str_arr = new[3];
        str_arr[0] = "hello";
        str_arr[1] = "world";
        str_arr[2] = "test";
        if (str_arr[0] == "hello" && str_arr[2] == "test") begin
            $display("PASS: string array");
            pass_count++;
        end else begin
            $display("FAIL: string array");
            fail_count++;
        end

        // Test string queue
        $display("\n--- String Queue ---");
        sq.push_back("a");
        sq.push_back("b");
        sq.push_back("c");
        if (sq.size() == 3 && sq[0] == "a") begin
            $display("PASS: string queue");
            pass_count++;
        end else begin
            $display("FAIL: string queue");
            fail_count++;
        end

        $display("");
        $display("=== Summary: %0d passed, %0d failed ===", pass_count, fail_count);
        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");
        $finish;
    end
endmodule
