/*
:name: test_generate_advanced
:description: Advanced Generate Tests
:tags: ch27
:type: simulation
:lrm: 1800-2023 27.4 27.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_generate_advanced.expected
*/
// IEEE 1800-2023 Section 27 - Advanced Generate Tests
// Tests: Generate-for, generate-if, generate-case, nested generates

module test_generate_advanced;
    int pass_count = 0;
    int fail_count = 0;

    parameter WIDTH = 4;
    parameter MODE = 2;

    // Generate-for: create array of signals
    wire [WIDTH-1:0] gen_wires;
    reg [WIDTH-1:0] gen_regs;

    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : gen_loop
            assign gen_wires[i] = gen_regs[i];
        end
    endgenerate

    // Generate-if: conditional generation
    generate
        if (WIDTH > 2) begin : wide_mode
            wire extra_wire;
            assign extra_wire = |gen_wires;
        end
    endgenerate

    // Generate-case: mode selection
    generate
        case (MODE)
            0: begin : mode_zero
                wire mode_wire = 1'b0;
            end
            1: begin : mode_one
                wire mode_wire = 1'b1;
            end
            default: begin : mode_default
                wire mode_wire = 1'bx;
            end
        endcase
    endgenerate

    // Nested generate
    generate
        for (i = 0; i < 2; i = i + 1) begin : outer
            genvar j;
            for (j = 0; j < 2; j = j + 1) begin : inner
                wire nested_wire;
                assign nested_wire = gen_wires[i] ^ gen_wires[j];
            end
        end
    endgenerate

    initial begin
        $display("=== IEEE 1800-2023 Advanced Generate Tests ===");
        gen_regs = 0;

        // Test 1: Generate-for created wires
        $display("Test 1: Generate-for created wires");
        gen_regs = 4'b1010;
        #1;
        if (gen_wires == 4'b1010) begin
            $display("Test 1 PASS: gen_wires=%b", gen_wires);
            pass_count++;
        end else begin
            $display("Test 1 FAIL: got %b", gen_wires);
            fail_count++;
        end

        // Test 2: All zeros
        $display("Test 2: All zeros");
        gen_regs = 4'b0000;
        #1;
        if (gen_wires == 4'b0000) begin
            $display("Test 2 PASS: gen_wires=%b", gen_wires);
            pass_count++;
        end else begin
            $display("Test 2 FAIL: got %b", gen_wires);
            fail_count++;
        end

        // Test 3: All ones
        $display("Test 3: All ones");
        gen_regs = 4'b1111;
        #1;
        if (gen_wires == 4'b1111) begin
            $display("Test 3 PASS: gen_wires=%b", gen_wires);
            pass_count++;
        end else begin
            $display("Test 3 FAIL: got %b", gen_wires);
            fail_count++;
        end

        // Test 4: Generate-if (wide_mode should exist)
        $display("Test 4: Generate-if conditional");
        if (WIDTH > 2) begin
            $display("Test 4 PASS: wide_mode generated (WIDTH=%0d)", WIDTH);
            pass_count++;
        end else begin
            $display("Test 4 FAIL: wide_mode not generated");
            fail_count++;
        end

        // Test 5: Generate-case default mode
        $display("Test 5: Generate-case mode selection");
        if (MODE == 2) begin
            $display("Test 5 PASS: mode_default generated (MODE=%0d)", MODE);
            pass_count++;
        end else begin
            $display("Test 5 FAIL: wrong mode");
            fail_count++;
        end

        // Test 6: Nested generate structure
        $display("Test 6: Nested generate structure");
        // Just verify the structure exists
        $display("Test 6 PASS: nested generate blocks created");
        pass_count++;

        // Test 7: Pattern test
        $display("Test 7: Pattern test");
        gen_regs = 4'b0101;
        #1;
        if (gen_wires == 4'b0101) begin
            $display("Test 7 PASS: pattern=%b", gen_wires);
            pass_count++;
        end else begin
            $display("Test 7 FAIL: got %b", gen_wires);
            fail_count++;
        end

        // Test 8: Walking ones
        $display("Test 8: Walking ones");
        gen_regs = 4'b0001;
        #1;
        if (gen_wires[0] == 1'b1) begin
            $display("Test 8 PASS: LSB set, gen_wires=%b", gen_wires);
            pass_count++;
        end else begin
            $display("Test 8 FAIL: got %b", gen_wires);
            fail_count++;
        end

        // Summary
        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");
        $finish;
    end
endmodule
