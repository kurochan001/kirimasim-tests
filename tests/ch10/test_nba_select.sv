/*
:name: test_nba_select
:description: Non-blocking assignment to bit/part select
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.4.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_nba_select.expected
*/
// IEEE 1800-2023 §10.4.2: Non-blocking assignment to bit/part select
// Test for NBA complex LHS (bit select, part select, indexed part select)

module test_nba_select;
    logic [7:0] sig1;
    logic [15:0] sig2;
    logic [31:0] sig3;
    int errors = 0;

    initial begin
        // Initialize
        sig1 = 8'h00;
        sig2 = 16'h0000;
        sig3 = 32'h00000000;

        // Test 1: Bit select NBA
        $display("Test 1: Bit select NBA");
        sig1[0] <= 1'b1;  // NBA to bit 0
        sig1[7] <= 1'b1;  // NBA to bit 7
        #1;
        if (sig1 !== 8'h81) begin
            $display("FAIL: Expected sig1 = 0x81, got 0x%h", sig1);
            errors++;
        end else begin
            $display("PASS: sig1 = 0x%h", sig1);
        end

        // Test 2: Part select NBA
        $display("Test 2: Part select NBA");
        sig2 = 16'h0000;
        sig2[7:0] <= 8'hAB;   // NBA to low byte
        sig2[15:8] <= 8'hCD;  // NBA to high byte
        #1;
        if (sig2 !== 16'hCDAB) begin
            $display("FAIL: Expected sig2 = 0xCDAB, got 0x%h", sig2);
            errors++;
        end else begin
            $display("PASS: sig2 = 0x%h", sig2);
        end

        // Test 3: Indexed part select (ascending) NBA
        $display("Test 3: Indexed part select (+:) NBA");
        sig3 = 32'h00000000;
        sig3[0+:8] <= 8'h11;   // bits [7:0]
        sig3[8+:8] <= 8'h22;   // bits [15:8]
        sig3[16+:8] <= 8'h33;  // bits [23:16]
        sig3[24+:8] <= 8'h44;  // bits [31:24]
        #1;
        if (sig3 !== 32'h44332211) begin
            $display("FAIL: Expected sig3 = 0x44332211, got 0x%h", sig3);
            errors++;
        end else begin
            $display("PASS: sig3 = 0x%h", sig3);
        end

        // Test 4: Multiple NBA to same signal in same time slot
        $display("Test 4: Multiple NBA to same signal");
        sig1 = 8'h00;
        sig1[3:0] <= 4'hA;  // NBA to low nibble
        sig1[7:4] <= 4'h5;  // NBA to high nibble
        #1;
        // Note: Both NBAs apply, last one to each bit range wins
        if (sig1 !== 8'h5A) begin
            $display("FAIL: Expected sig1 = 0x5A, got 0x%h", sig1);
            errors++;
        end else begin
            $display("PASS: sig1 = 0x%h", sig1);
        end

        // Test 5: NBA should not be visible before #delay
        $display("Test 5: NBA timing verification");
        sig1 = 8'hFF;
        sig1[0] <= 1'b0;
        if (sig1[0] !== 1'b1) begin
            $display("FAIL: NBA should not be visible immediately, sig1[0] = %b", sig1[0]);
            errors++;
        end else begin
            $display("PASS: NBA not visible immediately");
        end
        #1;
        if (sig1[0] !== 1'b0) begin
            $display("FAIL: NBA should be visible after #1, sig1[0] = %b", sig1[0]);
            errors++;
        end else begin
            $display("PASS: NBA visible after delay");
        end

        // Summary
        if (errors == 0) begin
            $display("\nTEST PASSED: All NBA select tests passed!");
        end else begin
            $display("\nTEST FAILED: %0d errors", errors);
        end
        $finish;
    end
endmodule
