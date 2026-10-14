/*
:name: test_always_ff_simple
:description: Always FF Simple Tests
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.2.2.4 10.4.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_always_ff_simple.expected
*/
// IEEE 1800-2023 Section 9.2.2.4 - Always FF Simple Tests
module test_always_ff_simple;
    int pass_count = 0;
    int fail_count = 0;
    
    logic clk = 0;
    logic [7:0] data_in = 0;
    logic [7:0] data_out;
    
    always_ff @(posedge clk) begin
        data_out <= data_in;
    end
    
    initial begin
        $display("=== IEEE 1800-2023 Always FF Simple Tests ===");
        
        // Test 1: Initial
        $display("Test 1: Initial");
        data_in = 8'h00;
        pass_count++;
        $display("Test 1 PASS");
        
        // Test 2: Set input
        $display("Test 2: Set input");
        data_in = 8'hAA;
        #1; clk = 1; #1; clk = 0; #1;
        if (data_out == 8'hAA) begin $display("Test 2 PASS: out=%h", data_out); pass_count++; end
        else begin $display("Test 2 FAIL: out=%h", data_out); fail_count++; end
        
        // Test 3: Change input
        $display("Test 3: Change");
        data_in = 8'hBB;
        #1; clk = 1; #1; clk = 0; #1;
        if (data_out == 8'hBB) begin $display("Test 3 PASS: out=%h", data_out); pass_count++; end
        else begin $display("Test 3 FAIL: out=%h", data_out); fail_count++; end
        
        // Test 4: FF pattern
        $display("Test 4: FF pattern");
        data_in = 8'hFF;
        #1; clk = 1; #1; clk = 0; #1;
        if (data_out == 8'hFF) begin $display("Test 4 PASS: out=%h", data_out); pass_count++; end
        else begin $display("Test 4 FAIL: out=%h", data_out); fail_count++; end
        
        // Test 5: Zero
        $display("Test 5: Zero");
        data_in = 8'h00;
        #1; clk = 1; #1; clk = 0; #1;
        if (data_out == 8'h00) begin $display("Test 5 PASS: out=%h", data_out); pass_count++; end
        else begin $display("Test 5 FAIL: out=%h", data_out); fail_count++; end
        
        // Test 6: 55 pattern
        $display("Test 6: 55 pattern");
        data_in = 8'h55;
        #1; clk = 1; #1; clk = 0; #1;
        if (data_out == 8'h55) begin $display("Test 6 PASS: out=%h", data_out); pass_count++; end
        else begin $display("Test 6 FAIL: out=%h", data_out); fail_count++; end
        
        // Test 7: AB pattern
        $display("Test 7: AB pattern");
        data_in = 8'hAB;
        #1; clk = 1; #1; clk = 0; #1;
        if (data_out == 8'hAB) begin $display("Test 7 PASS: out=%h", data_out); pass_count++; end
        else begin $display("Test 7 FAIL: out=%h", data_out); fail_count++; end
        
        // Test 8: CD pattern
        $display("Test 8: CD pattern");
        data_in = 8'hCD;
        #1; clk = 1; #1; clk = 0; #1;
        if (data_out == 8'hCD) begin $display("Test 8 PASS: out=%h", data_out); pass_count++; end
        else begin $display("Test 8 FAIL: out=%h", data_out); fail_count++; end
        
        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
