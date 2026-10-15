/*
:name: test_dynamic_array_size_edge
:description: Test dynamic array size() edge cases
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.5.2
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_dynamic_array_size_edge.expected
*/
// Test dynamic array size() edge cases
// IEEE 1800-2023 §7.4.2
module test_dynamic_array_size_edge;
    int pass_count = 0;
    int fail_count = 0;

    task automatic check(string name, int got, int expected);
        if (got == expected) begin
            $display("[PASS] %s: got %0d", name, got);
            pass_count++;
        end else begin
            $display("[FAIL] %s: expected %0d, got %0d", name, expected, got);
            fail_count++;
        end
    endtask

    // Test 1: Uninitialized dynamic array
    int dyn_arr1[];

    // Test 2: Class with dynamic array member
    class packet;
        bit [7:0] data[];

        function new();
        endfunction
    endclass

    // Test 3: Function returning dynamic array
    function automatic int get_dyn_size(int arr[]);
        return arr.size();
    endfunction

    initial begin
        packet pkt;
        int local_dyn[];
        int result;

        $display("=== Dynamic Array size() Edge Cases ===");
        $display("");

        // Test 1: Uninitialized module-level dynamic array
        $display("--- Test 1: Uninitialized module-level array ---");
        check("dyn_arr1.size() before init", dyn_arr1.size(), 0);

        // Test 2: Allocate and check
        dyn_arr1 = new[3];
        check("dyn_arr1.size() after new[3]", dyn_arr1.size(), 3);

        // Test 3: Resize
        dyn_arr1 = new[5](dyn_arr1);
        check("dyn_arr1.size() after resize to 5", dyn_arr1.size(), 5);

        // Test 4: Clear (set to 0 size)
        dyn_arr1 = new[0];
        check("dyn_arr1.size() after new[0]", dyn_arr1.size(), 0);

        $display("");

        // Test 5: Local dynamic array
        $display("--- Test 2: Local dynamic array ---");
        check("local_dyn.size() before init", local_dyn.size(), 0);
        local_dyn = new[4];
        check("local_dyn.size() after new[4]", local_dyn.size(), 4);

        $display("");

        // Test 6: Class member dynamic array
        $display("--- Test 3: Class member dynamic array ---");
        pkt = new();
        check("pkt.data.size() before init", pkt.data.size(), 0);
        pkt.data = new[7];
        check("pkt.data.size() after new[7]", pkt.data.size(), 7);

        $display("");

        // Test 7: Function parameter
        $display("--- Test 4: Function parameter ---");
        result = get_dyn_size(dyn_arr1);
        check("get_dyn_size(empty_arr)", result, 0);
        dyn_arr1 = new[6];
        result = get_dyn_size(dyn_arr1);
        check("get_dyn_size(arr[6])", result, 6);

        $display("");
        $display("=== Test Summary ===");
        $display("Pass: %0d, Fail: %0d", pass_count, fail_count);
        if (fail_count == 0) begin
            $display("ALL TESTS PASSED");
        end else begin
            $display("SOME TESTS FAILED");
        end
        $finish;
    end
endmodule
