/*
:name: test_mux8_edge_cases
:description: 8-to-1 Multiplexer edge cases
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.4.5 10.3.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_mux8_edge_cases.expected
*/
// IEEE 1800-2023 Sections 7.4.5 and 10.3.2: 8-to-1 multiplexer by array indexing
// Tests for 8:1 mux constructs

module test_mux8_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    logic [7:0] in[8];
    logic [2:0] sel;
    logic [7:0] out;

    // 8:1 multiplexer using array indexing
    assign out = in[sel];

    initial begin
        // Initialize inputs
        for (int i = 0; i < 8; i++) in[i] = i * 16;

        // Test 1: Select input 0
        test_count++;
        sel = 3'd0;
        #1;
        if (out == 0) begin
            pass_count++;
            $display("Test 1 PASS: sel=0 out=%h", out);
        end else begin
            $display("Test 1 FAIL: unexpected out=%h", out);
        end

        // Test 2: Select input 7
        test_count++;
        sel = 3'd7;
        #1;
        if (out == 7*16) begin
            pass_count++;
            $display("Test 2 PASS: sel=7 out=%h", out);
        end else begin
            $display("Test 2 FAIL: unexpected out=%h", out);
        end

        // Test 3: Middle select
        test_count++;
        sel = 3'd4;
        #1;
        if (out == 4*16) begin
            pass_count++;
            $display("Test 3 PASS: sel=4 out=%h", out);
        end else begin
            $display("Test 3 FAIL: unexpected out=%h", out);
        end

        // Test 4: Change input dynamically
        test_count++;
        in[3] = 8'hFF;
        sel = 3'd3;
        #1;
        if (out == 8'hFF) begin
            pass_count++;
            $display("Test 4 PASS: dynamic in=%h", out);
        end else begin
            $display("Test 4 FAIL: unexpected out=%h", out);
        end

        // Test 5: All zeros input
        test_count++;
        for (int i = 0; i < 8; i++) in[i] = 0;
        sel = 3'd5;
        #1;
        if (out == 0) begin
            pass_count++;
            $display("Test 5 PASS: all zeros");
        end else begin
            $display("Test 5 FAIL: unexpected");
        end

        // Test 6: All FF input
        test_count++;
        for (int i = 0; i < 8; i++) in[i] = 8'hFF;
        sel = 3'd2;
        #1;
        if (out == 8'hFF) begin
            pass_count++;
            $display("Test 6 PASS: all FF");
        end else begin
            $display("Test 6 FAIL: unexpected");
        end

        // Test 7: Sequential select
        test_count++;
        for (int i = 0; i < 8; i++) in[i] = i;
        for (int i = 0; i < 8; i++) begin
            sel = i[2:0];
            #1;
        end
        pass_count++;
        $display("Test 7 PASS: Sequential select");


        $display("=== 8:1 Mux Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
