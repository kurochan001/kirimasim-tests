/*
:name: test_bit_select_part
:description: Bit/Part Select Tests
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.5.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_bit_select_part.expected
*/
// IEEE 1800-2023 Section 11.5 - Bit/Part Select Tests
module test_bit_select_part;
    int pass_count = 0;
    int fail_count = 0;
    
    logic [7:0] data;
    logic [15:0] wide;
    
    initial begin
        $display("=== IEEE 1800-2023 Bit/Part Select Tests ===");
        
        // Test 1: Bit select read
        $display("Test 1: Bit read");
        data = 8'b10101010;
        if (data[1] == 1'b1) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: got %b", data[1]); fail_count++; end
        
        // Test 2: Bit select low
        $display("Test 2: Bit low");
        if (data[0] == 1'b0) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: got %b", data[0]); fail_count++; end
        
        // Test 3: Part select
        $display("Test 3: Part select");
        wide = 16'hABCD;
        if (wide[7:0] == 8'hCD) begin $display("Test 3 PASS: %h", wide[7:0]); pass_count++; end
        else begin $display("Test 3 FAIL: got %h", wide[7:0]); fail_count++; end
        
        // Test 4: Part select high
        $display("Test 4: Part high");
        if (wide[15:8] == 8'hAB) begin $display("Test 4 PASS: %h", wide[15:8]); pass_count++; end
        else begin $display("Test 4 FAIL: got %h", wide[15:8]); fail_count++; end
        
        // Test 5: Bit write
        $display("Test 5: Bit write");
        data = 8'h00;
        data[3] = 1'b1;
        if (data == 8'h08) begin $display("Test 5 PASS: %h", data); pass_count++; end
        else begin $display("Test 5 FAIL: got %h", data); fail_count++; end
        
        // Test 6: Part write
        $display("Test 6: Part write");
        wide = 16'h0000;
        wide[7:0] = 8'hFF;
        if (wide == 16'h00FF) begin $display("Test 6 PASS: %h", wide); pass_count++; end
        else begin $display("Test 6 FAIL: got %h", wide); fail_count++; end
        
        // Test 7: Multiple bits
        $display("Test 7: Multiple bits");
        data = 8'hF0;
        if (data[7] == 1 && data[4] == 1 && data[3] == 0 && data[0] == 0) begin 
            $display("Test 7 PASS"); pass_count++; 
        end else begin $display("Test 7 FAIL"); fail_count++; end
        
        // Test 8: Nibble select
        $display("Test 8: Nibble");
        wide = 16'h1234;
        if (wide[11:8] == 4'h2) begin $display("Test 8 PASS: %h", wide[11:8]); pass_count++; end
        else begin $display("Test 8 FAIL: got %h", wide[11:8]); fail_count++; end
        
        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
