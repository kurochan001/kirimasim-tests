/*
:name: test_struct_basic
:description: Struct Basic Tests
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_struct_basic.expected
*/
// IEEE 1800-2023 Section 7.2 - Struct Basic Tests
module test_struct_basic;
    int pass_count = 0;
    int fail_count = 0;
    
    typedef struct {
        int x;
        int y;
    } point_t;
    
    typedef struct {
        int value;
        bit valid;
    } data_t;
    
    initial begin
        point_t p1, p2;
        data_t d1;
        
        $display("=== IEEE 1800-2023 Struct Basic Tests ===");
        
        // Test 1: Member assign
        $display("Test 1: Member assign");
        p1.x = 10;
        p1.y = 20;
        if (p1.x == 10 && p1.y == 20) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL"); fail_count++; end
        
        // Test 2: Member read
        $display("Test 2: Member read");
        if (p1.x + p1.y == 30) begin $display("Test 2 PASS: sum=%0d", p1.x + p1.y); pass_count++; end
        else begin $display("Test 2 FAIL"); fail_count++; end
        
        // Test 3: Struct copy
        $display("Test 3: Struct copy");
        p2.x = p1.x;
        p2.y = p1.y;
        if (p2.x == 10 && p2.y == 20) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL"); fail_count++; end
        
        // Test 4: Different struct
        $display("Test 4: Data struct");
        d1.value = 100;
        d1.valid = 1;
        if (d1.value == 100 && d1.valid == 1) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL"); fail_count++; end
        
        // Test 5: Modify p1
        $display("Test 5: Modify");
        p1.x = p1.x + 5;
        if (p1.x == 15) begin $display("Test 5 PASS: x=%0d", p1.x); pass_count++; end
        else begin $display("Test 5 FAIL: got %0d", p1.x); fail_count++; end
        
        // Test 6: p2 unchanged
        $display("Test 6: p2 unchanged");
        if (p2.x == 10) begin $display("Test 6 PASS: p2.x=%0d", p2.x); pass_count++; end
        else begin $display("Test 6 FAIL: got %0d", p2.x); fail_count++; end
        
        // Test 7: Negative values
        $display("Test 7: Negative");
        p1.x = -10; p1.y = -20;
        if (p1.x == -10) begin $display("Test 7 PASS: x=%0d", p1.x); pass_count++; end
        else begin $display("Test 7 FAIL: got %0d", p1.x); fail_count++; end
        
        // Test 8: Zero values
        $display("Test 8: Zero");
        p2.x = 0; p2.y = 0;
        if (p2.x == 0 && p2.y == 0) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL"); fail_count++; end
        
        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
