/*
:name: test_always_comb_5
:description: always_comb infers its sensitivity from the expressions it reads
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.2.2.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_always_comb_5.expected
*/
// always_comb infers its sensitivity from the expressions it reads
// Tests automatic sensitivity list inference in always_comb blocks

module test_always_comb;
    logic a, b, c;
    logic [3:0] d, e;
    logic [7:0] result1, result2, result3;
    logic sel;
    logic [1:0] mux_sel;
    logic [3:0] mux_out;

    int pass_count = 0;
    int fail_count = 0;

    // Test 1: Simple combinational logic
    always_comb begin
        result1 = a & b;
    end

    // Test 2: Multiple inputs with different operators
    always_comb begin
        result2 = (d | e) ^ {4'b0, c, c, c, c};
    end

    // Test 3: Conditional expression in always_comb
    always_comb begin
        if (sel)
            result3 = {d, e};
        else
            result3 = {e, d};
    end

    // Test 4: Case statement in always_comb
    always_comb begin
        case (mux_sel)
            2'b00: mux_out = 4'h1;
            2'b01: mux_out = 4'h2;
            2'b10: mux_out = 4'h4;
            2'b11: mux_out = 4'h8;
            default: mux_out = 4'h0;
        endcase
    end

    // Test 5: Nested conditions
    logic [3:0] nested_out;
    always_comb begin
        if (a) begin
            if (b)
                nested_out = 4'hF;
            else
                nested_out = 4'hA;
        end else begin
            nested_out = 4'h0;
        end
    end

    initial begin
        // Test 1: Basic AND gate
        a = 0; b = 0;
        #1;
        if (result1 == 0) begin
            $display("PASS: Test 1a - always_comb AND gate (0 & 0 = 0)");
            pass_count++;
        end else begin
            $display("FAIL: Test 1a - expected 0, got %0d", result1);
            fail_count++;
        end

        a = 1; b = 1;
        #1;
        if (result1 == 1) begin
            $display("PASS: Test 1b - always_comb AND gate (1 & 1 = 1)");
            pass_count++;
        end else begin
            $display("FAIL: Test 1b - expected 1, got %0d", result1);
            fail_count++;
        end

        // Test 2: OR and XOR
        d = 4'hA; e = 4'h5; c = 0;
        #1;
        if (result2 == 8'h0F) begin
            $display("PASS: Test 2 - always_comb OR/XOR operations");
            pass_count++;
        end else begin
            $display("FAIL: Test 2 - expected 0x0F, got 0x%0h", result2);
            fail_count++;
        end

        // Test 3: Conditional concatenation
        d = 4'hA; e = 4'hB; sel = 1;
        #1;
        if (result3 == 8'hAB) begin
            $display("PASS: Test 3a - always_comb conditional (sel=1)");
            pass_count++;
        end else begin
            $display("FAIL: Test 3a - expected 0xAB, got 0x%0h", result3);
            fail_count++;
        end

        sel = 0;
        #1;
        if (result3 == 8'hBA) begin
            $display("PASS: Test 3b - always_comb conditional (sel=0)");
            pass_count++;
        end else begin
            $display("FAIL: Test 3b - expected 0xBA, got 0x%0h", result3);
            fail_count++;
        end

        // Test 4: Case statement
        mux_sel = 2'b10;
        #1;
        if (mux_out == 4'h4) begin
            $display("PASS: Test 4 - always_comb case statement");
            pass_count++;
        end else begin
            $display("FAIL: Test 4 - expected 0x4, got 0x%0h", mux_out);
            fail_count++;
        end

        // Test 5: Nested conditions
        a = 1; b = 0;
        #1;
        if (nested_out == 4'hA) begin
            $display("PASS: Test 5 - always_comb nested conditions");
            pass_count++;
        end else begin
            $display("FAIL: Test 5 - expected 0xA, got 0x%0h", nested_out);
            fail_count++;
        end

        $display("\n=== Summary: %0d PASS, %0d FAIL ===", pass_count, fail_count);
        if (fail_count == 0)
            $display("PASS: All always_comb tests passed");
        else
            $display("FAIL: Some tests failed");
        $finish;
    end
endmodule
