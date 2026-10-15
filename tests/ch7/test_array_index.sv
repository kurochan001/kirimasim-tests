/*
:name: test_array_index
:description: Array Index Tests
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_index.expected
*/
// IEEE 1800-2023 Section 7.4 - Array Index Tests
module test_array_index;
    int pass_count = 0;
    int fail_count = 0;
    
    int arr [4];
    int arr2d [2][3];
    
    initial begin
        $display("=== IEEE 1800-2023 Array Index Tests ===");
        
        // Test 1: Write index 0
        $display("Test 1: Write [0]");
        arr[0] = 100;
        if (arr[0] == 100) begin $display("Test 1 PASS: %0d", arr[0]); pass_count++; end
        else begin $display("Test 1 FAIL: got %0d", arr[0]); fail_count++; end
        
        // Test 2: Write all indices
        $display("Test 2: Write all");
        arr[0] = 10; arr[1] = 20; arr[2] = 30; arr[3] = 40;
        if (arr[0] + arr[1] + arr[2] + arr[3] == 100) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL"); fail_count++; end
        
        // Test 3: Read specific index
        $display("Test 3: Read [2]");
        if (arr[2] == 30) begin $display("Test 3 PASS: %0d", arr[2]); pass_count++; end
        else begin $display("Test 3 FAIL: got %0d", arr[2]); fail_count++; end
        
        // Test 4: Update index
        $display("Test 4: Update");
        arr[1] = arr[1] + 5;
        if (arr[1] == 25) begin $display("Test 4 PASS: %0d", arr[1]); pass_count++; end
        else begin $display("Test 4 FAIL: got %0d", arr[1]); fail_count++; end
        
        // Test 5: 2D array write
        $display("Test 5: 2D write");
        arr2d[0][0] = 1; arr2d[0][1] = 2; arr2d[0][2] = 3;
        arr2d[1][0] = 4; arr2d[1][1] = 5; arr2d[1][2] = 6;
        if (arr2d[0][0] == 1) begin $display("Test 5 PASS: %0d", arr2d[0][0]); pass_count++; end
        else begin $display("Test 5 FAIL: got %0d", arr2d[0][0]); fail_count++; end
        
        // Test 6: 2D array read
        $display("Test 6: 2D read");
        if (arr2d[1][2] == 6) begin $display("Test 6 PASS: %0d", arr2d[1][2]); pass_count++; end
        else begin $display("Test 6 FAIL: got %0d", arr2d[1][2]); fail_count++; end
        
        // Test 7: 2D sum
        $display("Test 7: 2D sum");
        if (arr2d[0][0] + arr2d[0][1] + arr2d[0][2] + arr2d[1][0] + arr2d[1][1] + arr2d[1][2] == 21) begin
            $display("Test 7 PASS"); pass_count++;
        end else begin $display("Test 7 FAIL"); fail_count++; end
        
        // Test 8: Copy element
        $display("Test 8: Copy");
        arr[3] = arr[0];
        if (arr[3] == 10) begin $display("Test 8 PASS: %0d", arr[3]); pass_count++; end
        else begin $display("Test 8 FAIL: got %0d", arr[3]); fail_count++; end
        
        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
