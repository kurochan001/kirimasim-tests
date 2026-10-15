/*
:name: test_clog2_4
:description: $clog2 calculations
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.8.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_clog2_4.expected
*/
// $clog2 calculations
module test_clog2;
    integer result;
    integer pass_count;

    initial begin
        pass_count = 0;

        // Test 1: $clog2 of powers of 2
        if ($clog2(1) == 0 && $clog2(2) == 1 && $clog2(4) == 2 && $clog2(8) == 3) begin
            $display("Test 1: $clog2 powers of 2 - PASS");
            $display("  clog2(1)=%0d, clog2(2)=%0d, clog2(4)=%0d, clog2(8)=%0d",
                     $clog2(1), $clog2(2), $clog2(4), $clog2(8));
            pass_count = pass_count + 1;
        end else begin
            $display("Test 1: $clog2 powers of 2 - FAIL");
        end

        // Test 2: $clog2 of non-powers of 2 (rounds up)
        if ($clog2(3) == 2 && $clog2(5) == 3 && $clog2(7) == 3 && $clog2(9) == 4) begin
            $display("Test 2: $clog2 non-powers - PASS");
            $display("  clog2(3)=%0d, clog2(5)=%0d, clog2(7)=%0d, clog2(9)=%0d",
                     $clog2(3), $clog2(5), $clog2(7), $clog2(9));
            pass_count = pass_count + 1;
        end else begin
            $display("Test 2: $clog2 non-powers - FAIL");
        end

        // Test 3: $clog2 of 0
        result = $clog2(0);
        if (result == 0) begin
            $display("Test 3: $clog2(0) = %0d - PASS", result);
            pass_count = pass_count + 1;
        end else begin
            $display("Test 3: $clog2(0) - FAIL (got %0d)", result);
        end

        // Test 4: $clog2 of large values
        if ($clog2(256) == 8 && $clog2(1024) == 10 && $clog2(65536) == 16) begin
            $display("Test 4: $clog2 large values - PASS");
            $display("  clog2(256)=%0d, clog2(1024)=%0d, clog2(65536)=%0d",
                     $clog2(256), $clog2(1024), $clog2(65536));
            pass_count = pass_count + 1;
        end else begin
            $display("Test 4: $clog2 large values - FAIL");
        end

        // Test 5: $clog2 used for address width calculation
        // For a memory of 1000 entries, need $clog2(1000) bits
        result = $clog2(1000);
        if (result == 10) begin  // 2^10 = 1024 >= 1000
            $display("Test 5: $clog2(1000) = %0d (address width) - PASS", result);
            pass_count = pass_count + 1;
        end else begin
            $display("Test 5: $clog2(1000) - FAIL (got %0d)", result);
        end

        if (pass_count == 5)
            $display("All clog2 tests PASS");
        else
            $display("Some tests FAIL: %0d/5 passed", pass_count);

        $finish;
    end
endmodule
