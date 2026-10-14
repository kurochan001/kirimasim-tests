/*
:name: test_dyn_array_basic
:description: Dynamic Array Basic Tests
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.5.1 7.5.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_dyn_array_basic.expected
*/
// IEEE 1800-2023 Section 7.5 - Dynamic Array Basic Tests
module test_dyn_array_basic;
    int pass_count = 0;
    int fail_count = 0;
    
    int dyn_arr[];
    
    initial begin
        $display("=== IEEE 1800-2023 Dynamic Array Basic Tests ===");
        
        // Test 1: New array
        $display("Test 1: New");
        dyn_arr = new[4];
        if (dyn_arr.size() == 4) begin $display("Test 1 PASS: size=%0d", dyn_arr.size()); pass_count++; end
        else begin $display("Test 1 FAIL: size=%0d", dyn_arr.size()); fail_count++; end
        
        // Test 2: Write elements
        $display("Test 2: Write");
        dyn_arr[0] = 10;
        dyn_arr[1] = 20;
        dyn_arr[2] = 30;
        dyn_arr[3] = 40;
        if (dyn_arr[2] == 30) begin $display("Test 2 PASS: [2]=%0d", dyn_arr[2]); pass_count++; end
        else begin $display("Test 2 FAIL: [2]=%0d", dyn_arr[2]); fail_count++; end
        
        // Test 3: Read elements
        $display("Test 3: Read");
        if (dyn_arr[0] + dyn_arr[3] == 50) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL"); fail_count++; end
        
        // Test 4: Resize larger
        $display("Test 4: Resize larger");
        dyn_arr = new[6](dyn_arr);
        dyn_arr[4] = 50;
        dyn_arr[5] = 60;
        if (dyn_arr.size() == 6 && dyn_arr[0] == 10) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL"); fail_count++; end
        
        // Test 5: Size check
        $display("Test 5: Size");
        if (dyn_arr.size() == 6) begin $display("Test 5 PASS: size=%0d", dyn_arr.size()); pass_count++; end
        else begin $display("Test 5 FAIL: size=%0d", dyn_arr.size()); fail_count++; end
        
        // Test 6: Sum elements
        $display("Test 6: Sum");
        if (dyn_arr[0] + dyn_arr[1] + dyn_arr[2] + dyn_arr[3] + dyn_arr[4] + dyn_arr[5] == 210) begin
            $display("Test 6 PASS"); pass_count++;
        end else begin $display("Test 6 FAIL"); fail_count++; end
        
        // Test 7: Delete
        $display("Test 7: Delete");
        dyn_arr.delete();
        if (dyn_arr.size() == 0) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL: size=%0d", dyn_arr.size()); fail_count++; end
        
        // Test 8: Recreate
        $display("Test 8: Recreate");
        dyn_arr = new[2];
        dyn_arr[0] = 100;
        dyn_arr[1] = 200;
        if (dyn_arr.size() == 2 && dyn_arr[1] == 200) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL"); fail_count++; end
        
        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
