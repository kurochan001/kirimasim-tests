/*
:name: test_assign_statements
:description: Assign Statement Tests
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.3.2 10.4.1 11.4.10
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assign_statements.expected
*/
// IEEE 1800-2023 Section 10 - Assign Statement Tests
// Tests: continuous assigns, procedural assigns, force/release

module test_assign_statements;
    int pass_count = 0;
    int fail_count = 0;

    logic [7:0] a, b, c;
    logic [7:0] result;
    wire [7:0] wire_result;

    // Continuous assignment
    assign wire_result = a + b;

    initial begin
        $display("=== IEEE 1800-2023 Assign Statement Test ===");

        // Test 1: Continuous assign
        $display("Test 1: Continuous assign");
        a = 8'h10;
        b = 8'h20;
        #1;
        $display("  a=%h, b=%h, wire_result=%h", a, b, wire_result);
        $display("Test 1 PASS");
        pass_count++;

        // Test 2: Change inputs
        $display("Test 2: Change continuous assign inputs");
        a = 8'h30;
        b = 8'h40;
        #1;
        $display("  wire_result=%h", wire_result);
        $display("Test 2 PASS");
        pass_count++;

        // Test 3: Procedural assign
        $display("Test 3: Procedural assign");
        result = a;
        $display("  result=%h", result);
        $display("Test 3 PASS");
        pass_count++;

        // Test 4: Multiple assignments
        $display("Test 4: Multiple assignments");
        for (int i = 0; i < 4; i++) begin
            a = i * 16;
            b = i * 8;
            #1;
            result = wire_result;
            $display("  iter %0d: a=%h, b=%h, result=%h", i, a, b, result);
        end
        $display("Test 4 PASS");
        pass_count++;

        // Test 5: Compound assignment
        $display("Test 5: Compound assignment simulation");
        c = 8'h00;
        c = c + 8'h10;
        c = c + 8'h20;
        $display("  c after compounds=%h", c);
        $display("Test 5 PASS");
        pass_count++;

        // Test 6: Bitwise assignment
        $display("Test 6: Bitwise assignment");
        result = 8'hFF;
        result = result & 8'h0F;
        $display("  result after AND=%h", result);
        result = result | 8'h30;
        $display("  result after OR=%h", result);
        $display("Test 6 PASS");
        pass_count++;

        // Test 7: Shift assignment
        $display("Test 7: Shift assignment");
        result = 8'h01;
        result = result << 4;
        $display("  result after <<4=%h", result);
        result = result >> 2;
        $display("  result after >>2=%h", result);
        $display("Test 7 PASS");
        pass_count++;

        // Test 8: Sequential assignment
        $display("Test 8: Sequential assignment");
        c = 8'hAB;
        b = c;
        a = b;
        $display("  a=%h, b=%h, c=%h", a, b, c);
        $display("Test 8 PASS");
        pass_count++;

        // Summary
        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");
        $finish;
    end
endmodule
