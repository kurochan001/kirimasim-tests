/*
:name: test_wire_logic
:description: 6.7 - Wire and Logic Tests
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_wire_logic.expected
*/
// IEEE 1800-2023 Section 6.5/6.7 - Wire and Logic Tests
module test_wire_logic;
    int pass_count = 0;
    int fail_count = 0;

    logic [7:0] log_val;
    wire [7:0] wire_val;
    reg [7:0] reg_val;

    assign wire_val = log_val;

    initial begin
        $display("=== IEEE 1800-2023 Wire Logic Tests ===");

        // Test 1: Logic assign
        $display("Test 1: Logic assign");
        log_val = 8'h55;
        #1;
        if (log_val == 8'h55) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: %h", log_val); fail_count++; end

        // Test 2: Wire follows
        $display("Test 2: Wire follows");
        if (wire_val == 8'h55) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: %h", wire_val); fail_count++; end

        // Test 3: Reg assign
        $display("Test 3: Reg assign");
        reg_val = 8'hAA;
        if (reg_val == 8'hAA) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL: %h", reg_val); fail_count++; end

        // Test 4: Update logic
        $display("Test 4: Update");
        log_val = 8'hFF;
        #1;
        if (log_val == 8'hFF && wire_val == 8'hFF) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL"); fail_count++; end

        // Test 5: Zero
        $display("Test 5: Zero");
        log_val = 8'h00;
        #1;
        if (wire_val == 8'h00) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: %h", wire_val); fail_count++; end

        // Test 6: Pattern
        $display("Test 6: Pattern");
        log_val = 8'b10101010;
        #1;
        if (wire_val == 8'hAA) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: %h", wire_val); fail_count++; end

        // Test 7: Reg independence
        $display("Test 7: Reg indep");
        reg_val = 8'h12;
        if (reg_val == 8'h12) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL: %h", reg_val); fail_count++; end

        // Test 8: Final check
        $display("Test 8: Final");
        log_val = 8'hCD;
        #1;
        if (wire_val == 8'hCD) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL: %h", wire_val); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
