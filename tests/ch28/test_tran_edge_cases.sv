/*
:name: test_tran_edge_cases
:description: Tran bidirectional edge cases
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.8
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_tran_edge_cases.expected
*/
// IEEE 1800-2023 §28.8: Tran bidirectional edge cases
// Tests for tran and tranif primitives

module test_tran_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    wire a, b;
    wire c, d;
    logic driver_a, driver_c;
    logic ctrl;

    tran (a, b);
    tranif1 (c, d, ctrl);

    assign a = driver_a;
    assign c = driver_c ? 1'b1 : 1'bz;

    initial begin
        driver_a = 0;
        driver_c = 0;
        ctrl = 0;
        #1;

        // Test 1: Tran passes value
        test_count++;
        if (b == 0) begin
            pass_count++;
            $display("Test 1 PASS: tran a->b = %b", b);
        end else begin
            $display("Test 1 FAIL: tran unexpected = %b", b);
        end

        // Test 2: Tran high
        test_count++;
        driver_a = 1;
        #1;
        if (b == 1) begin
            pass_count++;
            $display("Test 2 PASS: tran a=1, b=%b", b);
        end else begin
            $display("Test 2 FAIL: tran unexpected = %b", b);
        end

        // Test 3: tranif1 off (ctrl=0)
        test_count++;
        if (d === 1'bz) begin
            pass_count++;
            $display("Test 3 PASS: tranif1 off = %b", d);
        end else begin
            $display("Test 3 FAIL: tranif1 unexpected = %b", d);
        end

        // Test 4: tranif1 on (ctrl=1)
        test_count++;
        ctrl = 1;
        driver_c = 1;
        #1;
        if (d == 1) begin
            pass_count++;
            $display("Test 4 PASS: tranif1 on, d=%b", d);
        end else begin
            $display("Test 4 FAIL: tranif1 unexpected = %b", d);
        end

        // Test 5: tranif1 off again
        test_count++;
        ctrl = 0;
        #1;
        if (d === 1'bz) begin
            pass_count++;
            $display("Test 5 PASS: tranif1 off = %b", d);
        end else begin
            $display("Test 5 FAIL: tranif1 unexpected = %b", d);
        end

        // Test 6: Tran toggle
        test_count++;
        driver_a = 0;
        #1;
        if (b == 0) begin
            pass_count++;
            $display("Test 6 PASS: tran toggle = %b", b);
        end else begin
            $display("Test 6 FAIL: tran unexpected = %b", b);
        end

        // Test 7: Multiple toggles
        test_count++;
        driver_a = 1; #1;
        driver_a = 0; #1;
        driver_a = 1; #1;
        if (b == 1) begin
            pass_count++;
            $display("Test 7 PASS: multi toggle = %b", b);
        end else begin
            $display("Test 7 FAIL: unexpected = %b", b);
        end

        $display("=== Tran Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
