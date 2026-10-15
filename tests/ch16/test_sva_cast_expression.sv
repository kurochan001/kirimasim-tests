/*
:name: test_sva_cast_expression
:description: Test cast expressions in SVA
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.12 6.24.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sva_cast_expression.expected
*/
// IEEE 1800-2023 §16: Test cast expressions in SVA
// Tests type cast in assertions

module test_sva_cast_expression;
    logic clk = 0;
    logic [7:0] data;
    logic [15:0] wide_data;
    logic valid;

    // Clock generation
    always #5 clk = ~clk;

    int fail_count = 0;

    // Test 1: Unsigned cast in assertion
    property p_unsigned_cast;
        @(posedge clk) valid |-> (unsigned'(data) > 0);
    endproperty
    assert property (p_unsigned_cast) else begin
        $display("FAIL: p_unsigned_cast");
        fail_count++;
    end

    // Test 2: Signed cast in assertion (compare with positive value)
    property p_signed_cast;
        @(posedge clk) valid |-> ($signed(data) > 0);
    endproperty
    assert property (p_signed_cast) else begin
        $display("FAIL: p_signed_cast");
        fail_count++;
    end

    // Test 3: Width cast in assertion
    property p_width_cast;
        @(posedge clk) valid |-> (16'(data) < wide_data);
    endproperty
    assert property (p_width_cast) else begin
        $display("FAIL: p_width_cast");
        fail_count++;
    end

    initial begin
        // Initialize
        data = 8'h10;
        wide_data = 16'h100;
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
        $display("\n=== SVA Cast Expression Test ===");
        if (fail_count == 0) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED: %0d failures", fail_count);
        end

        $finish;
    end
endmodule
