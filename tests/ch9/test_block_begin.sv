/*
:name: test_block_begin
:description: Begin Block Tests
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.3.1 12.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_block_begin.expected
*/
// IEEE 1800-2023 Section 9.3.1 - Begin Block Tests
module test_block_begin;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        int a, b, c;

        $display("=== IEEE 1800-2023 Begin Block Tests ===");

        // Test 1-8: Block tests
        $display("Test 1: Simple block");
        begin
            a = 10;
        end
        if (a == 10) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL"); fail_count++; end

        $display("Test 2: Multi stmt");
        begin
            a = 1;
            b = 2;
            c = 3;
        end
        if (a == 1 && b == 2 && c == 3) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL"); fail_count++; end

        $display("Test 3: Nested block");
        begin
            a = 100;
            begin
                b = 200;
            end
        end
        if (a == 100 && b == 200) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL"); fail_count++; end

        $display("Test 4: Sequential");
        begin
            a = 1;
            a = a + 1;
            a = a + 1;
        end
        if (a == 3) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL: %0d", a); fail_count++; end

        $display("Test 5: Scope");
        a = 0;
        begin
            a = 50;
        end
        if (a == 50) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL"); fail_count++; end

        $display("Test 6: If block");
        a = 0;
        if (1) begin
            a = 99;
        end
        if (a == 99) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL"); fail_count++; end

        $display("Test 7: Else block");
        a = 0;
        if (0) begin
            a = 1;
        end else begin
            a = 2;
        end
        if (a == 2) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL"); fail_count++; end

        $display("Test 8: Chain block");
        begin a = 10; end
        begin b = 20; end
        begin c = a + b; end
        if (c == 30) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL"); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
