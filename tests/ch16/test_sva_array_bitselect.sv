/*
:name: test_sva_array_bitselect
:description: Test array and bit-select in SVA
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.12 16.6
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sva_array_bitselect.expected
*/
// IEEE 1800-2023 §16: Test array and bit-select in SVA
// Tests array access and bit-select in assertions

module test_sva_array_bitselect;
    logic clk = 0;
    logic [7:0] data;
    logic [3:0] arr [0:3];
    logic valid;

    // Clock generation
    always #5 clk = ~clk;

    int pass_count = 0;
    int fail_count = 0;

    // Test 1: Bit-select in assertion
    property p_bit_select;
        @(posedge clk) valid |-> (data[0] == 1'b1);
    endproperty
    assert property (p_bit_select) else begin
        $display("FAIL: p_bit_select");
        fail_count++;
    end

    // Test 2: Part-select in assertion
    property p_part_select;
        @(posedge clk) valid |-> (data[3:0] != 4'h0);
    endproperty
    assert property (p_part_select) else begin
        $display("FAIL: p_part_select");
        fail_count++;
    end

    // Test 3: Array element in assertion
    property p_array_element;
        @(posedge clk) valid |-> (arr[0] != 4'h0);
    endproperty
    assert property (p_array_element) else begin
        $display("FAIL: p_array_element");
        fail_count++;
    end

    // Test 4: Array element bit-select in assertion
    property p_array_bit_select;
        @(posedge clk) valid |-> (arr[1][0] == 1'b1);
    endproperty
    assert property (p_array_bit_select) else begin
        $display("FAIL: p_array_bit_select");
        fail_count++;
    end

    // Test 5: Multiple array accesses
    property p_multi_array;
        @(posedge clk) valid |-> (arr[0] + arr[1] > 4'h0);
    endproperty
    assert property (p_multi_array) else begin
        $display("FAIL: p_multi_array");
        fail_count++;
    end

    initial begin
        // Initialize
        data = 8'h01;
        arr[0] = 4'h1;
        arr[1] = 4'h3;
        arr[2] = 4'h5;
        arr[3] = 4'h7;
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
        $display("\n=== SVA Array/Bit-Select Test ===");
        if (fail_count == 0) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED: %0d failures", fail_count);
        end

        $finish;
    end
endmodule
