/*
:name: test_sysfunc_high_low
:description: $high and $low of packed, unpacked, dynamic and queue dimensions
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.7
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sysfunc_high_low.expected
*/
// $high and $low of packed, unpacked, dynamic and queue dimensions
module test_sysfunc_high_low;
    int pass_count = 0;
    int total_tests = 8;

    // Ascending range (low < high)
    logic [0:7] asc_vec;
    logic [7:0] asc_arr[0:9];

    // Descending range (high > low in declaration)
    logic [31:0] desc_vec;
    logic [15:0] desc_arr[9:0];

    // Multi-dimensional arrays
    logic [7:0] multi[4:1][8:3];

    // Dynamic and queue
    int dyn_arr[];
    int queue_arr[$];

    // Negative index range
    logic [7:0] neg_arr[-3:3];

    // Zero-based vs one-based
    logic [7:0] zero_based[0:4];
    logic [7:0] one_based[1:5];

    initial begin
        // Initialize
        dyn_arr = new[8];
        for (int i = 0; i < 6; i++) queue_arr.push_back(i);

        // Test 1: $high/$low of descending vector (31:0)
        // $high returns the numerically higher bound, $low returns lower
        if ($high(desc_vec) == 31 && $low(desc_vec) == 0) begin
            $display("Test 1 PASS: desc_vec[31:0]: $high=%0d, $low=%0d", $high(desc_vec), $low(desc_vec));
            pass_count++;
        end else begin
            $display("Test 1 FAIL: $high=%0d, $low=%0d", $high(desc_vec), $low(desc_vec));
        end

        // Test 2: $high/$low of ascending vector (0:7)
        if ($high(asc_vec) == 7 && $low(asc_vec) == 0) begin
            $display("Test 2 PASS: asc_vec[0:7]: $high=%0d, $low=%0d", $high(asc_vec), $low(asc_vec));
            pass_count++;
        end else begin
            $display("Test 2 FAIL: $high=%0d, $low=%0d", $high(asc_vec), $low(asc_vec));
        end

        // Test 3: $high/$low of descending array (9:0)
        if ($high(desc_arr) == 9 && $low(desc_arr) == 0) begin
            $display("Test 3 PASS: desc_arr[9:0]: $high=%0d, $low=%0d", $high(desc_arr), $low(desc_arr));
            pass_count++;
        end else begin
            $display("Test 3 FAIL: $high=%0d, $low=%0d", $high(desc_arr), $low(desc_arr));
        end

        // Test 4: Multi-dimensional first dimension (4:1)
        if ($high(multi, 1) == 4 && $low(multi, 1) == 1) begin
            $display("Test 4 PASS: multi dim1[4:1]: $high=%0d, $low=%0d", $high(multi, 1), $low(multi, 1));
            pass_count++;
        end else begin
            $display("Test 4 FAIL: dim1 bounds incorrect");
        end

        // Test 5: Multi-dimensional second dimension (8:3)
        if ($high(multi, 2) == 8 && $low(multi, 2) == 3) begin
            $display("Test 5 PASS: multi dim2[8:3]: $high=%0d, $low=%0d", $high(multi, 2), $low(multi, 2));
            pass_count++;
        end else begin
            $display("Test 5 FAIL: dim2 bounds incorrect");
        end

        // Test 6: Dynamic array
        if ($high(dyn_arr) == 7 && $low(dyn_arr) == 0) begin
            $display("Test 6 PASS: dyn_arr: $high=%0d, $low=%0d", $high(dyn_arr), $low(dyn_arr));
            pass_count++;
        end else begin
            $display("Test 6 FAIL: $high=%0d, $low=%0d", $high(dyn_arr), $low(dyn_arr));
        end

        // Test 7: Queue
        if ($high(queue_arr) == 5 && $low(queue_arr) == 0) begin
            $display("Test 7 PASS: queue_arr: $high=%0d, $low=%0d", $high(queue_arr), $low(queue_arr));
            pass_count++;
        end else begin
            $display("Test 7 FAIL: $high=%0d, $low=%0d", $high(queue_arr), $low(queue_arr));
        end

        // Test 8: Negative index range (-3:3)
        if ($high(neg_arr) == 3 && $low(neg_arr) == -3) begin
            $display("Test 8 PASS: neg_arr[-3:3]: $high=%0d, $low=%0d", $high(neg_arr), $low(neg_arr));
            pass_count++;
        end else begin
            $display("Test 8 FAIL: $high=%0d, $low=%0d", $high(neg_arr), $low(neg_arr));
        end

        $display("PASS: sysfunc_high_low (%0d/%0d)", pass_count, total_tests);
        $finish;
    end
endmodule
