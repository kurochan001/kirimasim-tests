/*
:name: test_adder_edge_cases
:description: Adder edge cases
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.3.2 11.4.3 11.6.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_adder_edge_cases.expected
*/
// IEEE 1800-2023: Adder edge cases
// Tests for adder constructs

module test_adder_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    logic [7:0] a, b;
    logic cin;
    logic [7:0] sum;
    logic cout;

    // Ripple carry adder
    assign {cout, sum} = a + b + cin;

    initial begin
        // Test 1: 0 + 0 + 0
        test_count++;
        a = 0; b = 0; cin = 0;
        #1;
        if (sum == 0 && cout == 0) begin
            pass_count++;
            $display("Test 1 PASS: 0+0+0=%0d cout=%b", sum, cout);
        end else begin
            $display("Test 1 FAIL: unexpected sum=%0d", sum);
        end

        // Test 2: Max + 1 (overflow)
        test_count++;
        a = 8'hFF; b = 8'h01; cin = 0;
        #1;
        if (sum == 0 && cout == 1) begin
            pass_count++;
            $display("Test 2 PASS: FF+01=%h cout=%b", sum, cout);
        end else begin
            $display("Test 2 FAIL: unexpected sum=%h", sum);
        end

        // Test 3: Carry in effect
        test_count++;
        a = 8'h00; b = 8'h00; cin = 1;
        #1;
        if (sum == 1) begin
            pass_count++;
            $display("Test 3 PASS: 0+0+1=%0d", sum);
        end else begin
            $display("Test 3 FAIL: unexpected sum=%0d", sum);
        end

        // Test 4: Mid-range addition
        test_count++;
        a = 8'h55; b = 8'hAA; cin = 0;
        #1;
        if (sum == 8'hFF) begin
            pass_count++;
            $display("Test 4 PASS: 55+AA=%h", sum);
        end else begin
            $display("Test 4 FAIL: unexpected sum=%h", sum);
        end

        // Test 5: All ones + carry in
        test_count++;
        a = 8'hFF; b = 8'hFF; cin = 1;
        #1;
        if (cout == 1) begin
            pass_count++;
            $display("Test 5 PASS: FF+FF+1=%h cout=%b", sum, cout);
        end else begin
            $display("Test 5 FAIL: unexpected");
        end

        // Test 6: Boundary value
        test_count++;
        a = 8'h80; b = 8'h80; cin = 0;
        #1;
        if (sum == 0 && cout == 1) begin
            pass_count++;
            $display("Test 6 PASS: 80+80=%h cout=%b", sum, cout);
        end else begin
            $display("Test 6 FAIL: unexpected sum=%h", sum);
        end

        // Test 7: Small values
        test_count++;
        a = 8'h01; b = 8'h02; cin = 0;
        #1;
        if (sum == 3) begin
            pass_count++;
            $display("Test 7 PASS: 1+2=%0d", sum);
        end else begin
            $display("Test 7 FAIL: unexpected sum=%0d", sum);
        end

        $display("=== Adder Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
