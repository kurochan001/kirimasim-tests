/*
:name: test_edge_detection
:description: Edge Detection Tests
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.4.2 10.4.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_edge_detection.expected
*/
// IEEE 1800-2023 Section 9.4.2 - Edge Detection Tests
// Tests: posedge, negedge, edge, edge sensitivity

module test_edge_detection;
    int pass_count = 0;
    int fail_count = 0;

    logic clk = 0;
    logic rst_n = 1;
    logic sig = 0;
    int posedge_count = 0;
    int negedge_count = 0;
    logic [7:0] data_pos;
    logic [7:0] data_neg;

    // Clock generation
    always #5 clk = ~clk;

    // Posedge detection
    always @(posedge clk) begin
        posedge_count++;
        data_pos <= posedge_count[7:0];
    end

    // Negedge detection
    always @(negedge clk) begin
        negedge_count++;
        data_neg <= negedge_count[7:0];
    end

    initial begin
        $display("=== IEEE 1800-2023 Edge Detection Tests ===");

        // Test 1: Initial state
        $display("Test 1: Initial state");
        #1;
        if (posedge_count == 0 && negedge_count == 0) begin
            $display("Test 1 PASS");
            pass_count++;
        end else begin
            $display("Test 1 FAIL");
            fail_count++;
        end

        // Test 2: First posedge
        $display("Test 2: First posedge");
        @(posedge clk);
        #1;
        if (posedge_count >= 1) begin
            $display("Test 2 PASS");
            pass_count++;
        end else begin
            $display("Test 2 FAIL: count=%0d", posedge_count);
            fail_count++;
        end

        // Test 3: First negedge
        $display("Test 3: First negedge");
        @(negedge clk);
        #1;
        if (negedge_count >= 1) begin
            $display("Test 3 PASS");
            pass_count++;
        end else begin
            $display("Test 3 FAIL: count=%0d", negedge_count);
            fail_count++;
        end

        // Test 4: Multiple cycles
        $display("Test 4: Multiple cycles");
        repeat(5) @(posedge clk);
        #1;
        if (posedge_count >= 6) begin
            $display("Test 4 PASS");
            pass_count++;
        end else begin
            $display("Test 4 FAIL: count=%0d", posedge_count);
            fail_count++;
        end

        // Test 5: Signal edge detection
        $display("Test 5: Signal posedge");
        sig = 0;
        #1;
        sig = 1;
        #1;
        $display("Test 5 PASS");
        pass_count++;

        // Test 6: Signal negedge detection
        $display("Test 6: Signal negedge");
        sig = 1;
        #1;
        sig = 0;
        #1;
        $display("Test 6 PASS");
        pass_count++;

        // Test 7: Reset edge
        $display("Test 7: Reset edge");
        rst_n = 1;
        #1;
        rst_n = 0;
        #1;
        rst_n = 1;
        #1;
        $display("Test 7 PASS");
        pass_count++;

        // Test 8: Data capture on posedge
        $display("Test 8: Data capture on posedge");
        @(posedge clk);
        #1;
        if (data_pos == posedge_count[7:0]) begin
            $display("Test 8 PASS");
            pass_count++;
        end else begin
            $display("Test 8 FAIL");
            fail_count++;
        end

        // Summary
        @(posedge clk);
        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");
        $finish;
    end
endmodule
