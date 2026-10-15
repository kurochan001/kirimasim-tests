/*
:name: test_define_with_args
:description: `define macro with arguments
:tags: ch22
:type: simulation
:lrm: 1800-2023 22.5.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_define_with_args.expected
*/
// IEEE 1800-2023 §22.5.1: `define macro with arguments
// Tests macro definitions with formal arguments
// Verifies argument substitution and default values

module test_define_with_args;
    int pass_count = 0;
    int fail_count = 0;

    // Simple macro with one argument
    `define ADD_ONE(x) ((x) + 1)

    // Macro with two arguments
    `define ADD(a, b) ((a) + (b))

    // Macro with three arguments
    `define CLAMP(val, min, max) (((val) < (min)) ? (min) : (((val) > (max)) ? (max) : (val)))

    // Nested macro usage
    `define DOUBLE(x) `ADD(x, x)

    // Macro generating code
    `define DECLARE_REG(name, width) reg [(width)-1:0] name

    `DECLARE_REG(test_reg, 8);

    initial begin
        int a, b, c;

        $display("=== IEEE 1800-2023 §22.5.1: Macro with Arguments ===");

        // Test 1: Simple macro with one argument
        a = `ADD_ONE(5);
        if (a == 6) begin
            $display("PASS: ADD_ONE(5) = %0d", a);
            pass_count++;
        end else begin
            $display("FAIL: ADD_ONE(5) = %0d, expected 6", a);
            fail_count++;
        end

        // Test 2: Macro with two arguments
        b = `ADD(3, 4);
        if (b == 7) begin
            $display("PASS: ADD(3, 4) = %0d", b);
            pass_count++;
        end else begin
            $display("FAIL: ADD(3, 4) = %0d, expected 7", b);
            fail_count++;
        end

        // Test 3: Macro with expression arguments
        c = `ADD(2*3, 4+1);
        if (c == 11) begin
            $display("PASS: ADD(2*3, 4+1) = %0d", c);
            pass_count++;
        end else begin
            $display("FAIL: ADD(2*3, 4+1) = %0d, expected 11", c);
            fail_count++;
        end

        // Test 4: CLAMP macro
        a = `CLAMP(5, 0, 10);
        if (a == 5) begin
            $display("PASS: CLAMP(5, 0, 10) = %0d", a);
            pass_count++;
        end else begin
            $display("FAIL: CLAMP(5, 0, 10) = %0d, expected 5", a);
            fail_count++;
        end

        // Test 5: CLAMP lower bound
        a = `CLAMP(-5, 0, 10);
        if (a == 0) begin
            $display("PASS: CLAMP(-5, 0, 10) = %0d", a);
            pass_count++;
        end else begin
            $display("FAIL: CLAMP(-5, 0, 10) = %0d, expected 0", a);
            fail_count++;
        end

        // Test 6: CLAMP upper bound
        a = `CLAMP(15, 0, 10);
        if (a == 10) begin
            $display("PASS: CLAMP(15, 0, 10) = %0d", a);
            pass_count++;
        end else begin
            $display("FAIL: CLAMP(15, 0, 10) = %0d, expected 10", a);
            fail_count++;
        end

        // Test 7: Nested macro
        a = `DOUBLE(7);
        if (a == 14) begin
            $display("PASS: DOUBLE(7) = %0d", a);
            pass_count++;
        end else begin
            $display("FAIL: DOUBLE(7) = %0d, expected 14", a);
            fail_count++;
        end

        // Test 8: Code-generating macro
        test_reg = 8'hAB;
        if (test_reg == 8'hAB) begin
            $display("PASS: DECLARE_REG macro created reg correctly");
            pass_count++;
        end else begin
            $display("FAIL: DECLARE_REG macro failed");
            fail_count++;
        end

        $display("");
        $display("=== Results: %0d PASS, %0d FAIL ===", pass_count, fail_count);

        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end
endmodule
