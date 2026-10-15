/*
:name: test_always_latch_2
:description: always_latch holds its outputs while the condition is false
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.2.2.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_always_latch_2.expected
*/
// always_latch holds its outputs while the condition is false
// Tests latch inference and behavior in always_latch blocks

module test_always_latch;
    logic enable;
    logic [7:0] data_in;
    logic [7:0] latch_out;

    logic sel;
    logic [3:0] partial_in;
    logic [3:0] partial_latch;

    logic [1:0] case_sel;
    logic [7:0] case_latch;

    int pass_count = 0;
    int fail_count = 0;

    // Test 1: Simple transparent latch
    always_latch begin
        if (enable)
            latch_out = data_in;
    end

    // Test 2: Partial latch with condition
    always_latch begin
        if (sel)
            partial_latch = partial_in;
    end

    // Test 3: Case-based latch (incomplete case creates latch)
    always_latch begin
        case (case_sel)
            2'b00: case_latch = 8'h11;
            2'b01: case_latch = 8'h22;
            2'b10: case_latch = 8'h33;
            // Missing 2'b11 creates latch behavior
        endcase
    end

    // Test 4: Nested latch conditions
    logic cond1, cond2;
    logic [3:0] nested_latch;
    always_latch begin
        if (cond1) begin
            if (cond2)
                nested_latch = 4'hF;
        end
    end

    // Test 5: Multiple outputs in one latch block
    logic gate;
    logic [3:0] multi_a, multi_b;
    always_latch begin
        if (gate) begin
            multi_a = 4'hA;
            multi_b = 4'hB;
        end
    end

    initial begin
        // Initialize
        enable = 0;
        data_in = 8'h00;
        sel = 0;
        partial_in = 4'h0;
        case_sel = 2'b00;
        cond1 = 0;
        cond2 = 0;
        gate = 0;
        #1;

        // Test 1: Latch transparency
        data_in = 8'hAB;
        enable = 1;
        #1;
        if (latch_out == 8'hAB) begin
            $display("PASS: Test 1a - Latch transparent when enabled");
            pass_count++;
        end else begin
            $display("FAIL: Test 1a - expected 0xAB, got 0x%0h", latch_out);
            fail_count++;
        end

        // Test 1b: Latch holds when disabled
        enable = 0;
        data_in = 8'hCD;
        #1;
        if (latch_out == 8'hAB) begin
            $display("PASS: Test 1b - Latch holds value when disabled");
            pass_count++;
        end else begin
            $display("FAIL: Test 1b - expected 0xAB (held), got 0x%0h", latch_out);
            fail_count++;
        end

        // Test 2: Partial latch
        partial_in = 4'h5;
        sel = 1;
        #1;
        if (partial_latch == 4'h5) begin
            $display("PASS: Test 2a - Partial latch passes through");
            pass_count++;
        end else begin
            $display("FAIL: Test 2a - expected 0x5, got 0x%0h", partial_latch);
            fail_count++;
        end

        sel = 0;
        partial_in = 4'hF;
        #1;
        if (partial_latch == 4'h5) begin
            $display("PASS: Test 2b - Partial latch holds");
            pass_count++;
        end else begin
            $display("FAIL: Test 2b - expected 0x5 (held), got 0x%0h", partial_latch);
            fail_count++;
        end

        // Test 3: Case-based latch
        case_sel = 2'b01;
        #1;
        if (case_latch == 8'h22) begin
            $display("PASS: Test 3a - Case latch updates on valid case");
            pass_count++;
        end else begin
            $display("FAIL: Test 3a - expected 0x22, got 0x%0h", case_latch);
            fail_count++;
        end

        case_sel = 2'b11; // Missing case - should hold
        #1;
        if (case_latch == 8'h22) begin
            $display("PASS: Test 3b - Case latch holds on missing case");
            pass_count++;
        end else begin
            $display("FAIL: Test 3b - expected 0x22 (held), got 0x%0h", case_latch);
            fail_count++;
        end

        // Test 4: Nested conditions
        cond1 = 1; cond2 = 1;
        #1;
        if (nested_latch == 4'hF) begin
            $display("PASS: Test 4 - Nested latch condition");
            pass_count++;
        end else begin
            $display("FAIL: Test 4 - expected 0xF, got 0x%0h", nested_latch);
            fail_count++;
        end

        // Test 5: Multiple outputs
        gate = 1;
        #1;
        if (multi_a == 4'hA && multi_b == 4'hB) begin
            $display("PASS: Test 5 - Multiple outputs in latch block");
            pass_count++;
        end else begin
            $display("FAIL: Test 5 - expected A/B, got 0x%0h/0x%0h", multi_a, multi_b);
            fail_count++;
        end

        $display("\n=== Summary: %0d PASS, %0d FAIL ===", pass_count, fail_count);
        if (fail_count == 0)
            $display("PASS: All always_latch tests passed");
        else
            $display("FAIL: Some tests failed");
        $finish;
    end
endmodule
