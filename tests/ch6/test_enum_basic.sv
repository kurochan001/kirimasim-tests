/*
:name: test_enum_basic
:description: Enum Basic Tests
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.19
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_enum_basic.expected
*/
// IEEE 1800-2023 Section 6.19 - Enum Basic Tests
module test_enum_basic;
    int pass_count = 0;
    int fail_count = 0;
    
    typedef enum {RED, GREEN, BLUE} color_t;
    typedef enum {IDLE=0, RUN=1, STOP=2, ERROR=3} state_t;
    
    initial begin
        color_t c;
        state_t s;
        
        $display("=== IEEE 1800-2023 Enum Basic Tests ===");
        
        // Test 1: Enum assign
        $display("Test 1: Assign");
        c = RED;
        if (c == RED) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL"); fail_count++; end
        
        // Test 2: Enum compare
        $display("Test 2: Compare");
        c = GREEN;
        if (c == GREEN && c != RED) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL"); fail_count++; end
        
        // Test 3: Enum value
        $display("Test 3: Value");
        if (RED == 0 && GREEN == 1 && BLUE == 2) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL"); fail_count++; end
        
        // Test 4: Explicit values
        $display("Test 4: Explicit");
        s = IDLE;
        if (s == 0) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL"); fail_count++; end
        
        // Test 5: State transition
        $display("Test 5: State");
        s = RUN;
        if (s == 1) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL"); fail_count++; end
        
        // Test 6: Reassign
        $display("Test 6: Reassign");
        c = RED;
        c = BLUE;
        if (c == BLUE) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL"); fail_count++; end
        
        // Test 7: State sequence
        $display("Test 7: Sequence");
        s = IDLE;
        s = RUN;
        s = STOP;
        if (s == 2) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL"); fail_count++; end
        
        // Test 8: Error state
        $display("Test 8: Error state");
        s = ERROR;
        if (s == 3) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL"); fail_count++; end
        
        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
