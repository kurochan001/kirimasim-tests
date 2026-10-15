/*
:name: test_sva_range_select
:description: Test range select in SVA
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.12 11.4.13
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sva_range_select.expected
*/
// IEEE 1800-2023 §16: Test range select in SVA
// Tests part-select and inside range expressions

module test_sva_range_select;
    logic clk = 0;
    logic [7:0] data;
    logic valid;

    // Clock generation
    always #5 clk = ~clk;

    int fail_count = 0;

    // Test 1: Part-select [high:low] in assertion
    property p_part_select;
        @(posedge clk) valid |-> (data[7:4] != 4'h0);
    endproperty
    assert property (p_part_select) else begin
        $display("FAIL: p_part_select");
        fail_count++;
    end

    // Test 2: Part-select comparison
    property p_part_select_compare;
        @(posedge clk) valid |-> (data[3:0] > 4'h0);
    endproperty
    assert property (p_part_select_compare) else begin
        $display("FAIL: p_part_select_compare");
        fail_count++;
    end

    // Test 3: Inside with range
    property p_inside_range;
        @(posedge clk) valid |-> (data inside {[8'h10:8'hF0]});
    endproperty
    assert property (p_inside_range) else begin
        $display("FAIL: p_inside_range");
        fail_count++;
    end

    initial begin
        // Initialize
        data = 8'h51;  // Binary: 0101_0001
        valid = 0;

        // Wait for clock
        @(posedge clk);
        @(posedge clk);

        // Enable valid and test
        valid = 1;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);

        // Disable valid
        valid = 0;
        @(posedge clk);

        // Summary
        $display("\n=== SVA Range Select Test ===");
        if (fail_count == 0) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED: %0d failures", fail_count);
        end

        $finish;
    end
endmodule
