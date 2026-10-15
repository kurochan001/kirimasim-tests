/*
:name: test_assign_var
:description: Variable procedural assign
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.4 11.4.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assign_var.expected
*/
// Variable procedural assign
// Verifies procedural assignment to variables

module test_assign_var;
    logic [7:0] a, b, c;
    logic [15:0] wide;
    int counter;
    logic [7:0] result;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        // Test 1: Simple blocking assignment
        a = 8'hAA;
        if (a === 8'hAA) begin
            $display("PASS: Scenario 1 - Blocking assign (a=0x%h)", a);
            pass_count++;
        end else begin
            $display("FAIL: Scenario 1 - a=0x%h (expected 0xAA)", a);
            fail_count++;
        end

        // Test 2: Assignment from expression
        b = 8'h55;
        c = a + b;
        if (c === 8'hFF) begin
            $display("PASS: Scenario 2 - Expression assign (c=0x%h)", c);
            pass_count++;
        end else begin
            $display("FAIL: Scenario 2 - c=0x%h (expected 0xFF)", c);
            fail_count++;
        end

        // Test 3: Compound assignment
        counter = 10;
        counter += 5;
        if (counter === 15) begin
            $display("PASS: Scenario 3 - Compound += (counter=%0d)", counter);
            pass_count++;
        end else begin
            $display("FAIL: Scenario 3 - counter=%0d (expected 15)", counter);
            fail_count++;
        end

        // Test 4: Multiple compound operations
        counter -= 3;
        counter *= 2;
        if (counter === 24) begin
            $display("PASS: Scenario 4 - Multiple compound (counter=%0d)", counter);
            pass_count++;
        end else begin
            $display("FAIL: Scenario 4 - counter=%0d (expected 24)", counter);
            fail_count++;
        end

        // Test 5: Bit-select assignment
        wide = 16'h0000;
        wide[7:0] = 8'hAB;
        wide[15:8] = 8'hCD;
        if (wide === 16'hCDAB) begin
            $display("PASS: Scenario 5 - Bit-select assign (wide=0x%h)", wide);
            pass_count++;
        end else begin
            $display("FAIL: Scenario 5 - wide=0x%h (expected 0xCDAB)", wide);
            fail_count++;
        end

        // Test 6: Increment/decrement
        counter = 10;
        counter++;
        if (counter === 11) begin
            $display("PASS: Scenario 6a - Increment (counter=%0d)", counter);
            pass_count++;
        end else begin
            $display("FAIL: Scenario 6a - counter=%0d (expected 11)", counter);
            fail_count++;
        end

        counter--;
        counter--;
        if (counter === 9) begin
            $display("PASS: Scenario 6b - Decrement (counter=%0d)", counter);
            pass_count++;
        end else begin
            $display("FAIL: Scenario 6b - counter=%0d (expected 9)", counter);
            fail_count++;
        end

        // Test 7: Conditional assignment
        a = 8'h10;
        b = 8'h20;
        result = (a > b) ? a : b;
        if (result === 8'h20) begin
            $display("PASS: Scenario 7 - Conditional assign (result=0x%h)", result);
            pass_count++;
        end else begin
            $display("FAIL: Scenario 7 - result=0x%h (expected 0x20)", result);
            fail_count++;
        end

        // Summary
        $display("Variable procedural assign: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0) $display("PASS");
        else $display("FAIL");
        $finish;
    end
endmodule
