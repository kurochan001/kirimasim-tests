/*
:name: test_operator_relational
:description: Relational operators
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.4
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_operator_relational.expected
*/
// Relational operators
module test_operator_relational;
    int a, b;
    logic [7:0] ua, ub;
    logic signed [7:0] sa, sb;
    real ra, rb;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        // Test 1: Less than (<) and greater than (>)
        a = 5;
        b = 10;
        if ((a < b) && !(a > b) && !(b < a) && (b > a)) begin
            $display("PASS: Test 1 - Less/greater than");
            pass_count++;
        end else begin
            $display("FAIL: Test 1 - Less/greater than failed");
            fail_count++;
        end

        // Test 2: Less than or equal (<=) and greater than or equal (>=)
        a = 10;
        b = 10;
        if ((a <= b) && (a >= b) && !(a < b) && !(a > b)) begin
            $display("PASS: Test 2 - Less/greater or equal");
            pass_count++;
        end else begin
            $display("FAIL: Test 2 - Less/greater or equal failed");
            fail_count++;
        end

        // Test 3: Unsigned comparison
        ua = 8'hFF;  // 255
        ub = 8'h01;  // 1
        if (ua > ub) begin
            $display("PASS: Test 3 - Unsigned comparison");
            pass_count++;
        end else begin
            $display("FAIL: Test 3 - Unsigned comparison failed");
            fail_count++;
        end

        // Test 4: Signed comparison
        sa = -1;   // 8'hFF as signed = -1
        sb = 1;    // 8'h01 as signed = 1
        if (sa < sb) begin
            $display("PASS: Test 4 - Signed comparison");
            pass_count++;
        end else begin
            $display("FAIL: Test 4 - Signed comparison failed");
            fail_count++;
        end

        // Test 5: Real comparison
        ra = 3.14;
        rb = 3.15;
        if ((ra < rb) && (rb > ra) && !(ra >= rb)) begin
            $display("PASS: Test 5 - Real comparison");
            pass_count++;
        end else begin
            $display("FAIL: Test 5 - Real comparison failed");
            fail_count++;
        end

        // Summary
        $display("Operator Relational: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0) $display("PASS: All tests passed");
        else $display("FAIL: Some tests failed");
        $finish;
    end
endmodule
