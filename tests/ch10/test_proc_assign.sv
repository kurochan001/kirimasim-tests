/*
:name: test_proc_assign
:description: Procedural Assignment Tests
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_proc_assign.expected
*/
// IEEE 1800-2023 Section 10.4 - Procedural Assignment Tests
module test_proc_assign;
    int pass_count = 0;
    int fail_count = 0;

    int a, b, c;
    logic [7:0] data;

    initial begin
        $display("=== IEEE 1800-2023 Procedural Assignment Tests ===");

        $display("Test 1: Simple assign");
        a = 10;
        if (a == 10) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: %0d", a); fail_count++; end

        $display("Test 2: Expression assign");
        b = a + 5;
        if (b == 15) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: %0d", b); fail_count++; end

        $display("Test 3: Chain assign");
        c = b;
        b = a;
        a = c;
        if (a == 15 && b == 10) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL"); fail_count++; end

        $display("Test 4: Logic assign");
        data = 8'hAB;
        if (data == 8'hAB) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL"); fail_count++; end

        $display("Test 5: Compound add");
        a = 10;
        a = a + 1;
        if (a == 11) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: %0d", a); fail_count++; end

        $display("Test 6: Compound mult");
        a = 5;
        a = a * 2;
        if (a == 10) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: %0d", a); fail_count++; end

        $display("Test 7: Ternary assign");
        a = (b > 5) ? 100 : 200;
        if (a == 100) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL: %0d", a); fail_count++; end

        $display("Test 8: Multi expr");
        a = 1;
        b = 2;
        c = a + b + 3;
        if (c == 6) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL: %0d", c); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
