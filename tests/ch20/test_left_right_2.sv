/*
:name: test_left_right_2
:description: $left, $right, $low, $high
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.7
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_left_right_2.expected
*/
// $left, $right, $low, $high
module test_left_right;
    logic [7:0] ascending;           // [7:0] - left=7, right=0
    logic [0:7] descending;          // [0:7] - left=0, right=7
    logic [15:8] offset_range;       // [15:8] - left=15, right=8
    logic [7:0] arr [0:3];           // Unpacked [0:3]
    logic [7:0] arr2 [3:0];          // Unpacked [3:0]

    integer pass_count;

    initial begin
        pass_count = 0;

        // Test 1: $left and $right for [7:0]
        if ($left(ascending) == 7 && $right(ascending) == 0) begin
            $display("Test 1: [7:0] left=%0d, right=%0d - PASS",
                     $left(ascending), $right(ascending));
            pass_count = pass_count + 1;
        end else begin
            $display("Test 1: [7:0] - FAIL");
        end

        // Test 2: $left and $right for [0:7] (ascending)
        if ($left(descending) == 0 && $right(descending) == 7) begin
            $display("Test 2: [0:7] left=%0d, right=%0d - PASS",
                     $left(descending), $right(descending));
            pass_count = pass_count + 1;
        end else begin
            $display("Test 2: [0:7] - FAIL");
        end

        // Test 3: $low and $high
        if ($low(ascending) == 0 && $high(ascending) == 7) begin
            if ($low(descending) == 0 && $high(descending) == 7) begin
                $display("Test 3: $low/$high - PASS");
                $display("  [7:0]: low=%0d, high=%0d", $low(ascending), $high(ascending));
                $display("  [0:7]: low=%0d, high=%0d", $low(descending), $high(descending));
                pass_count = pass_count + 1;
            end else begin
                $display("Test 3: $low/$high descending - FAIL");
            end
        end else begin
            $display("Test 3: $low/$high ascending - FAIL");
        end

        // Test 4: Offset range [15:8]
        if ($left(offset_range) == 15 && $right(offset_range) == 8 &&
            $low(offset_range) == 8 && $high(offset_range) == 15) begin
            $display("Test 4: [15:8] left=%0d, right=%0d, low=%0d, high=%0d - PASS",
                     $left(offset_range), $right(offset_range),
                     $low(offset_range), $high(offset_range));
            pass_count = pass_count + 1;
        end else begin
            $display("Test 4: [15:8] - FAIL");
        end

        // Test 5: Unpacked array dimensions
        // For arr[0:3]: left=0, right=3, low=0, high=3
        // For arr2[3:0]: left=3, right=0, low=0, high=3
        if ($left(arr) == 0 && $right(arr) == 3 &&
            $left(arr2) == 3 && $right(arr2) == 0) begin
            $display("Test 5: Unpacked arrays - PASS");
            $display("  [0:3]: left=%0d, right=%0d", $left(arr), $right(arr));
            $display("  [3:0]: left=%0d, right=%0d", $left(arr2), $right(arr2));
            pass_count = pass_count + 1;
        end else begin
            $display("Test 5: Unpacked arrays - FAIL");
        end

        if (pass_count == 5)
            $display("All left/right/low/high tests PASS");
        else
            $display("Some tests FAIL: %0d/5 passed", pass_count);

        $finish;
    end
endmodule
