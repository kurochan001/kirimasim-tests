/*
:name: test_reg_edge_cases
:description: reg variables: initial x, x and z values, selects, signed reg
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.8 6.11
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_reg_edge_cases.expected
*/
// IEEE 1800-2023 §6.7: Reg edge cases
// Tests for 4-state reg type (variable)

module test_reg_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    reg r;
    reg [7:0] rvec;
    reg [15:0] rword;
    reg signed [7:0] rs;

    initial begin
        // Test 1: Default value (X for 4-state)
        test_count++;
        // A 4-state variable without an initializer starts as x (6.8).
        if (r === 1'bx) begin
            pass_count++;
            $display("Test 1 PASS: Default = %b", r);
        end else begin
            $display("Test 1 FAIL: Default unexpected = %b", r);
        end

        // Test 2: Assignment 0
        test_count++;
        r = 0;
        if (r == 0) begin
            pass_count++;
            $display("Test 2 PASS: r = 0");
        end else begin
            $display("Test 2 FAIL: Assign unexpected = %b", r);
        end

        // Test 3: Assignment 1
        test_count++;
        r = 1;
        if (r == 1) begin
            pass_count++;
            $display("Test 3 PASS: r = 1");
        end else begin
            $display("Test 3 FAIL: Assign unexpected = %b", r);
        end

        // Test 4: Assignment X
        test_count++;
        r = 1'bx;
        if (r === 1'bx) begin
            pass_count++;
            $display("Test 4 PASS: r = X");
        end else begin
            $display("Test 4 FAIL: X unexpected = %b", r);
        end

        // Test 5: Assignment Z
        test_count++;
        r = 1'bz;
        if (r === 1'bz) begin
            pass_count++;
            $display("Test 5 PASS: r = Z");
        end else begin
            $display("Test 5 FAIL: Z unexpected = %b", r);
        end

        // Test 6: Vector assignment
        test_count++;
        rvec = 8'hAA;
        if (rvec == 8'hAA) begin
            pass_count++;
            $display("Test 6 PASS: rvec = %h", rvec);
        end else begin
            $display("Test 6 FAIL: Vec unexpected = %h", rvec);
        end

        // Test 7: Vector with X
        test_count++;
        rvec = 8'bxxxx_1010;
        if (rvec[3:0] == 4'hA) begin
            pass_count++;
            $display("Test 7 PASS: rvec[3:0] = %h", rvec[3:0]);
        end else begin
            $display("Test 7 FAIL: Vec X unexpected");
        end

        // Test 8: Vector with Z
        test_count++;
        rvec = 8'bzzzz_1111;
        if (rvec[3:0] == 4'hF) begin
            pass_count++;
            $display("Test 8 PASS: rvec[3:0] = %h", rvec[3:0]);
        end else begin
            $display("Test 8 FAIL: Vec Z unexpected");
        end

        // Test 9: Word assignment
        test_count++;
        rword = 16'h1234;
        if (rword == 16'h1234) begin
            pass_count++;
            $display("Test 9 PASS: rword = %h", rword);
        end else begin
            $display("Test 9 FAIL: Word unexpected = %h", rword);
        end

        // Test 10: Signed reg
        test_count++;
        rs = -8'sd50;
        if (rs < 0) begin
            pass_count++;
            $display("Test 10 PASS: rs = %0d", rs);
        end else begin
            $display("Test 10 FAIL: Signed unexpected = %0d", rs);
        end

        // Test 11: Bitwise AND
        test_count++;
        rvec = 8'hF0;
        begin
            static reg [7:0] res;
            // Assigned here so the result does not depend on the order of static initializers.
            res = rvec & 8'h0F;
            if (res == 8'h00) begin
                pass_count++;
                $display("Test 11 PASS: AND = %h", res);
            end else begin
                $display("Test 11 FAIL: AND unexpected = %h", res);
            end
        end

        // Test 12: Bitwise OR
        test_count++;
        rvec = 8'hF0;
        begin
            static reg [7:0] res;
            // Assigned here so the result does not depend on the order of static initializers.
            res = rvec | 8'h0F;
            if (res == 8'hFF) begin
                pass_count++;
                $display("Test 12 PASS: OR = %h", res);
            end else begin
                $display("Test 12 FAIL: OR unexpected = %h", res);
            end
        end

        // Test 13: Bit select
        test_count++;
        rvec = 8'b1010_0101;
        if (rvec[0] == 1 && rvec[7] == 1) begin
            pass_count++;
            $display("Test 13 PASS: Bit select");
        end else begin
            $display("Test 13 FAIL: Bit unexpected");
        end

        // Test 14: Part select
        test_count++;
        rword = 16'hABCD;
        if (rword[7:0] == 8'hCD) begin
            pass_count++;
            $display("Test 14 PASS: Part = %h", rword[7:0]);
        end else begin
            $display("Test 14 FAIL: Part unexpected = %h", rword[7:0]);
        end

        // Test 15: Concatenation
        test_count++;
        rvec = 8'hAB;
        begin
            static reg [15:0] cat;
            // Assigned here so the result does not depend on the order of static initializers.
            cat = {rvec, 8'hCD};
            if (cat == 16'hABCD) begin
                pass_count++;
                $display("Test 15 PASS: Concat = %h", cat);
            end else begin
                $display("Test 15 FAIL: Concat unexpected = %h", cat);
            end
        end

        $display("=== Reg Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
