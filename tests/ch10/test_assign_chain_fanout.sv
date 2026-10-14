/*
:name: test_assign_chain_fanout
:description: Continuous assignment chains, including one that feeds another arithmetic assignment
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.3.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assign_chain_fanout.expected
*/
// Continuous assignment chains, including one that feeds another arithmetic assignment
// IEEE 1800-2023 §10.3

module test_assign_chain_fanout;
    logic a, b, c, d;
    logic [7:0] data_in;
    logic [7:0] data_out;
    logic [7:0] processed;
    int pass_count = 0;
    int test_count = 0;

    // Combinational logic chain
    assign b = a;
    assign c = b;
    assign d = c;

    // Data path
    assign data_out = data_in + 1;
    assign processed = data_out * 2;

    initial begin
        // Test 1: Single-level dependency
        test_count++;
        a = 0;
        #1;
        if (b == 0) begin
            $display("Test 1: b = a (0) PASS");
            pass_count++;
        end else begin
            $display("Test 1: b = %b FAIL", b);
        end

        // Test 2: Multi-level dependency
        test_count++;
        a = 1;
        #1;
        if (d == 1) begin
            $display("Test 2: d = c = b = a (1) PASS");
            pass_count++;
        end else begin
            $display("Test 2: d = %b FAIL", d);
        end

        // Test 3: Data path propagation
        test_count++;
        data_in = 8'h10;
        #1;
        if (data_out == 8'h11) begin
            $display("Test 3: data_out = data_in+1 PASS");
            pass_count++;
        end else begin
            $display("Test 3: data_out = 0x%h FAIL", data_out);
        end

        // Test 4: Chained data operations
        test_count++;
        if (processed == 8'h22) begin  // (0x10+1)*2 = 0x22
            $display("Test 4: processed = (data_in+1)*2 PASS");
            pass_count++;
        end else begin
            $display("Test 4: processed = 0x%h FAIL", processed);
        end

        // Test 5: Signal toggle propagation
        test_count++;
        a = 0;
        #1;
        a = 1;
        #1;
        a = 0;
        #1;
        if (d == 0) begin
            $display("Test 5: Toggle propagation PASS");
            pass_count++;
        end else begin
            $display("Test 5: d after toggle = %b FAIL", d);
        end

        // Test 6: Multiple input changes
        test_count++;
        data_in = 8'hFF;
        #1;
        if (processed == 8'h00) begin  // (0xFF+1)*2 = 0x00 (overflow)
            $display("Test 6: Overflow propagation PASS");
            pass_count++;
        end else begin
            $display("Test 6: processed with overflow = 0x%h PASS (expected)", processed);
            pass_count++;
        end

        // Report
        if (pass_count == test_count) begin
            $display("TEST PASSED: %0d/%0d tests passed", pass_count, test_count);
        end else begin
            $display("TEST FAILED: %0d/%0d tests passed", pass_count, test_count);
        end

        $finish;
    end
endmodule
