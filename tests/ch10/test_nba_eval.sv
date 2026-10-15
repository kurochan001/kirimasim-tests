/*
:name: test_nba_eval
:description: Non-Blocking Assignment Evaluation Tests
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.4.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_nba_eval.expected
*/
// IEEE 1800-2023 Section 10.4.2 - Non-Blocking Assignment Evaluation Tests
module test_nba_eval;
    int pass_count = 0;
    int fail_count = 0;

    logic [7:0] reg_a, reg_b, reg_c;

    initial begin
        $display("=== IEEE 1800-2023 NBA Evaluation Tests ===");

        $display("Test 1: Simple NBA");
        reg_a = 8'h00;
        reg_a <= 8'hAB;
        #1;
        if (reg_a == 8'hAB) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: %h", reg_a); fail_count++; end

        $display("Test 2: Swap with NBA");
        reg_a = 8'h11;
        reg_b = 8'h22;
        reg_a <= reg_b;
        reg_b <= reg_a;
        #1;
        if (reg_a == 8'h22 && reg_b == 8'h11) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: a=%h, b=%h", reg_a, reg_b); fail_count++; end

        $display("Test 3: Chain NBA");
        reg_a = 8'h33;
        reg_b = 8'h44;
        reg_c = 8'h55;
        reg_a <= reg_b;
        reg_b <= reg_c;
        reg_c <= reg_a;
        #1;
        if (reg_a == 8'h44 && reg_b == 8'h55 && reg_c == 8'h33) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL: a=%h, b=%h, c=%h", reg_a, reg_b, reg_c); fail_count++; end

        $display("Test 4: NBA value read");
        reg_a = 8'h10;
        reg_a <= reg_a + 8'h01;
        #1;
        if (reg_a == 8'h11) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL: %h", reg_a); fail_count++; end

        $display("Test 5: Multiple NBA same reg");
        reg_a = 8'h00;
        reg_a <= 8'h01;
        reg_a <= 8'h02;
        #1;
        if (reg_a == 8'h02) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: %h", reg_a); fail_count++; end

        $display("Test 6: Mixed assign");
        reg_a = 8'hFF;
        reg_b <= 8'hEE;
        #1;
        if (reg_a == 8'hFF && reg_b == 8'hEE) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: a=%h, b=%h", reg_a, reg_b); fail_count++; end

        $display("Test 7: Expression NBA");
        reg_a = 8'h05;
        reg_b = 8'h03;
        reg_c <= reg_a + reg_b;
        #1;
        if (reg_c == 8'h08) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL: %h", reg_c); fail_count++; end

        $display("Test 8: Const NBA");
        reg_a <= 8'hCD;
        #1;
        if (reg_a == 8'hCD) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL: %h", reg_a); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
