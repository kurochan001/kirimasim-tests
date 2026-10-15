/*
:name: test_latch_edge_cases
:description: A D latch in always_latch: pass and hold
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.2.2.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_latch_edge_cases.expected
*/
// IEEE 1800-2023: Latch edge cases
// Tests for latch constructs

module test_latch_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    logic [7:0] din;
    logic en;
    logic [7:0] q;

    // D-latch (level sensitive)
    always_latch begin
        if (en)
            q = din;
    end

    initial begin
        // Test 1: Transparent when enabled
        test_count++;
        din = 8'hAA; en = 1;
        #1;
        if (q == 8'hAA) begin
            pass_count++;
            $display("Test 1 PASS: en=1 q=%h", q);
        end else begin
            $display("Test 1 FAIL: unexpected q=%h", q);
        end

        // Test 2: Hold when disabled
        test_count++;
        en = 0;
        din = 8'h55;
        #1;
        if (q == 8'hAA) begin
            pass_count++;
            $display("Test 2 PASS: hold q=%h", q);
        end else begin
            $display("Test 2 FAIL: unexpected q=%h", q);
        end

        // Test 3: Pass through new value
        test_count++;
        en = 1;
        #1;
        if (q == 8'h55) begin
            pass_count++;
            $display("Test 3 PASS: pass q=%h", q);
        end else begin
            $display("Test 3 FAIL: unexpected q=%h", q);
        end

        // Test 4: All zeros
        test_count++;
        din = 8'h00; en = 1;
        #1;
        if (q == 0) begin
            pass_count++;
            $display("Test 4 PASS: zeros q=%h", q);
        end else begin
            $display("Test 4 FAIL: unexpected");
        end

        // Test 5: All ones
        test_count++;
        din = 8'hFF; en = 1;
        #1;
        if (q == 8'hFF) begin
            pass_count++;
            $display("Test 5 PASS: ones q=%h", q);
        end else begin
            $display("Test 5 FAIL: unexpected");
        end

        // Test 6: Multiple changes while enabled
        test_count++;
        en = 1;
        din = 8'h11; #1;
        din = 8'h22; #1;
        din = 8'h33; #1;
        if (q == 8'h33) begin
            pass_count++;
            $display("Test 6 PASS: multi q=%h", q);
        end else begin
            $display("Test 6 FAIL: unexpected");
        end

        // Test 7: Toggle enable
        test_count++;
        din = 8'hAB; en = 1; #1;
        en = 0; #1;
        din = 8'hCD; #1;
        if (q == 8'hAB) begin
            pass_count++;
            $display("Test 7 PASS: toggle q=%h", q);
        end else begin
            $display("Test 7 FAIL: unexpected");
        end

        $display("=== Latch Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
