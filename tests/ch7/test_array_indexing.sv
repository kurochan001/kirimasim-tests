/*
:name: test_array_indexing
:description: Test: Array element access [i]
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.4 7.5 7.8 7.10 11.5.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_indexing.expected
*/
// Test: Array element access [i]

module test_array_indexing;
    int pass_count = 0;
    int total_tests = 25;

    // Test variables
    int arr[10];
    logic [7:0] byte_arr[8];
    int multi_arr[4][4];
    int dyn_arr[];
    int assoc_arr[string];
    int queue_arr[$];
    int idx;
    logic [31:0] packed_arr;

    initial begin
        // Test 1: Basic array read
        arr[0] = 100;
        if (arr[0] == 100) begin
            $display("Test 1 PASSED: arr[0] = 100");
            pass_count++;
        end else $display("Test 1 FAILED");

        // Test 2: Array write and read
        arr[5] = 555;
        if (arr[5] == 555) begin
            $display("Test 2 PASSED: arr[5] = 555");
            pass_count++;
        end else $display("Test 2 FAILED");

        // Test 3: Variable index
        idx = 3;
        arr[idx] = 333;
        if (arr[3] == 333) begin
            $display("Test 3 PASSED: arr[idx] with idx=3");
            pass_count++;
        end else $display("Test 3 FAILED");

        // Test 4: Expression as index
        arr[2 + 1] = 999;
        if (arr[3] == 999) begin
            $display("Test 4 PASSED: arr[2+1] = 999");
            pass_count++;
        end else $display("Test 4 FAILED");

        // Test 5: Logic array
        byte_arr[0] = 8'hAB;
        if (byte_arr[0] == 8'hAB) begin
            $display("Test 5 PASSED: byte_arr[0] = 0xAB");
            pass_count++;
        end else $display("Test 5 FAILED");

        // Test 6: Initialize multiple elements
        for (int i = 0; i < 8; i++) begin
            byte_arr[i] = i * 16;
        end
        if (byte_arr[4] == 8'h40) begin
            $display("Test 6 PASSED: byte_arr[4] = 0x40");
            pass_count++;
        end else $display("Test 6 FAILED");

        // Test 7: Multi-dimensional array
        multi_arr[0][0] = 11;
        multi_arr[1][2] = 42;
        if (multi_arr[1][2] == 42) begin
            $display("Test 7 PASSED: multi_arr[1][2] = 42");
            pass_count++;
        end else $display("Test 7 FAILED");

        // Test 8: Multi-dimensional with variables
        idx = 2;
        multi_arr[idx][idx] = 99;
        if (multi_arr[2][2] == 99) begin
            $display("Test 8 PASSED: multi_arr[2][2] = 99");
            pass_count++;
        end else $display("Test 8 FAILED");

        // Test 9: Dynamic array create
        dyn_arr = new[5];
        dyn_arr[0] = 10;
        if (dyn_arr[0] == 10) begin
            $display("Test 9 PASSED: dyn_arr[0] = 10");
            pass_count++;
        end else $display("Test 9 FAILED");

        // Test 10: Dynamic array all elements
        for (int i = 0; i < 5; i++) begin
            dyn_arr[i] = i * 100;
        end
        if (dyn_arr[4] == 400) begin
            $display("Test 10 PASSED: dyn_arr[4] = 400");
            pass_count++;
        end else $display("Test 10 FAILED");

        // Test 11: Associative array string key
        assoc_arr["first"] = 1;
        assoc_arr["second"] = 2;
        if (assoc_arr["first"] == 1) begin
            $display("Test 11 PASSED: assoc_arr[\"first\"] = 1");
            pass_count++;
        end else $display("Test 11 FAILED");

        // Test 12: Queue push and access
        queue_arr.push_back(100);
        queue_arr.push_back(200);
        if (queue_arr[0] == 100) begin
            $display("Test 12 PASSED: queue_arr[0] = 100");
            pass_count++;
        end else $display("Test 12 FAILED");

        // Test 13: Queue second element
        if (queue_arr[1] == 200) begin
            $display("Test 13 PASSED: queue_arr[1] = 200");
            pass_count++;
        end else $display("Test 13 FAILED");

        // Test 14: Array element in expression
        arr[0] = 10;
        arr[1] = 20;
        if (arr[0] + arr[1] == 30) begin
            $display("Test 14 PASSED: arr[0] + arr[1] = 30");
            pass_count++;
        end else $display("Test 14 FAILED");

        // Test 15: Array element as index
        arr[0] = 2;
        arr[2] = 999;
        if (arr[arr[0]] == 999) begin
            $display("Test 15 PASSED: arr[arr[0]] = 999");
            pass_count++;
        end else $display("Test 15 FAILED");

        // Test 16: Packed array bit select
        packed_arr = 32'hABCD_EF01;
        if (packed_arr[0] == 1'b1) begin
            $display("Test 16 PASSED: packed_arr[0] = 1");
            pass_count++;
        end else $display("Test 16 FAILED");

        // Test 17: Packed array higher bit
        if (packed_arr[31] == 1'b1) begin
            $display("Test 17 PASSED: packed_arr[31] = 1");
            pass_count++;
        end else $display("Test 17 FAILED");

        // Test 18: Array bounds - last element
        arr[9] = 909;
        if (arr[9] == 909) begin
            $display("Test 18 PASSED: arr[9] = 909");
            pass_count++;
        end else $display("Test 18 FAILED");

        // Test 19: Increment array element
        arr[0] = 50;
        arr[0] = arr[0] + 1;
        if (arr[0] == 51) begin
            $display("Test 19 PASSED: arr[0]++ = 51");
            pass_count++;
        end else $display("Test 19 FAILED");

        // Test 20: Swap using temp
        arr[0] = 10;
        arr[1] = 20;
        begin
            int temp;
            temp = arr[0];
            arr[0] = arr[1];
            arr[1] = temp;
        end
        if (arr[0] == 20 && arr[1] == 10) begin
            $display("Test 20 PASSED: swap arr[0] and arr[1]");
            pass_count++;
        end else $display("Test 20 FAILED");

        // Test 21: Negative values in array
        arr[0] = -100;
        if (arr[0] == -100) begin
            $display("Test 21 PASSED: arr[0] = -100");
            pass_count++;
        end else $display("Test 21 FAILED");

        // Test 22: Zero index always valid
        byte_arr[0] = 8'hFF;
        if (byte_arr[0] == 8'hFF) begin
            $display("Test 22 PASSED: byte_arr[0] = 0xFF");
            pass_count++;
        end else $display("Test 22 FAILED");

        // Test 23: Multi-dimensional diagonal
        for (int i = 0; i < 4; i++) begin
            multi_arr[i][i] = i * 11;
        end
        if (multi_arr[3][3] == 33) begin
            $display("Test 23 PASSED: multi_arr[3][3] = 33");
            pass_count++;
        end else $display("Test 23 FAILED");

        // Test 24: Queue with index modification
        queue_arr[0] = 999;
        if (queue_arr[0] == 999) begin
            $display("Test 24 PASSED: queue_arr[0] modified to 999");
            pass_count++;
        end else $display("Test 24 FAILED");

        // Test 25: Conditional index
        idx = 1;
        arr[idx ? 5 : 0] = 555;
        if (arr[5] == 555) begin
            $display("Test 25 PASSED: arr[idx?5:0] = 555");
            pass_count++;
        end else $display("Test 25 FAILED");

        if (pass_count == total_tests) $display("PASS: array_indexing (%0d/%0d)", pass_count, total_tests);
        else $display("FAIL: array_indexing (%0d/%0d)", pass_count, total_tests);
        $finish;
    end
endmodule
