/*
:name: test_tri_edge_cases
:description: tri, tri0 and tri1 nets with and without drivers
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.6.1 6.6.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_tri_edge_cases.expected
*/
// IEEE 1800-2023 §6.6.1, §6.6.5: Tri (tristate) edge cases
// Tests for tri net type

module test_tri_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    tri t;
    tri [7:0] tvec;
    tri1 t1;
    tri0 t0;

    logic driver1, driver2;
    logic [7:0] vec_driver;

    assign t = driver1 ? 1'b1 : 1'bz;
    assign tvec = vec_driver;

    initial begin
        driver1 = 0;
        driver2 = 0;
        vec_driver = 8'hzz;
        #1;

        // Test 1: Tri default (high-Z)
        test_count++;
        if (t === 1'bz) begin
            pass_count++;
            $display("Test 1 PASS: tri Z = %b", t);
        end else begin
            $display("Test 1 FAIL: tri unexpected = %b", t);
        end

        // Test 2: Tri driven high
        test_count++;
        driver1 = 1;
        #1;
        if (t == 1) begin
            pass_count++;
            $display("Test 2 PASS: tri driven = %b", t);
        end else begin
            $display("Test 2 FAIL: driven unexpected = %b", t);
        end

        // Test 3: Tri vector Z
        test_count++;
        vec_driver = 8'hzz;
        #1;
        if (tvec === 8'hzz) begin
            pass_count++;
            $display("Test 3 PASS: tvec Z = %h", tvec);
        end else begin
            $display("Test 3 FAIL: tvec unexpected = %h", tvec);
        end

        // Test 4: Tri vector driven
        test_count++;
        vec_driver = 8'hAB;
        #1;
        if (tvec == 8'hAB) begin
            pass_count++;
            $display("Test 4 PASS: tvec = %h", tvec);
        end else begin
            $display("Test 4 FAIL: tvec unexpected = %h", tvec);
        end

        // Test 5: Tri1 default (pull-up)
        test_count++;
        // An undriven tri1 net is 1 and an undriven tri0 net is 0 (6.6.5).
        if (t1 === 1'b1) begin
            pass_count++;
            $display("Test 5 PASS: tri1 = %b", t1);
        end else begin
            $display("Test 5 FAIL: tri1 unexpected = %b", t1);
        end

        // Test 6: Tri0 default (pull-down)
        test_count++;
        if (t0 === 1'b0) begin
            pass_count++;
            $display("Test 6 PASS: tri0 = %b", t0);
        end else begin
            $display("Test 6 FAIL: tri0 unexpected = %b", t0);
        end

        // Test 7: Partial Z in vector
        test_count++;
        vec_driver = 8'bzzzz_1010;
        #1;
        if (tvec[3:0] == 4'hA) begin
            pass_count++;
            $display("Test 7 PASS: partial = %h", tvec[3:0]);
        end else begin
            $display("Test 7 FAIL: partial unexpected");
        end

        // Test 8: Tri release
        test_count++;
        driver1 = 0;
        #1;
        if (t === 1'bz) begin
            pass_count++;
            $display("Test 8 PASS: released = %b", t);
        end else begin
            $display("Test 8 FAIL: release unexpected = %b", t);
        end

        // Test 9: Tri conditional
        test_count++;
        begin
            static logic result;
            // t is released (z) here; a static initializer would have read it
            // before simulation started.
            result = (t === 1'bz) ? 1'b0 : t;
            if (result === 1'b0) begin
                pass_count++;
                $display("Test 9 PASS: conditional = %b", result);
            end else begin
                $display("Test 9 FAIL: conditional = %b", result);
            end
        end

        // Test 10: Tri comparison
        test_count++;
        vec_driver = 8'h55;
        #1;
        if (tvec == 8'h55) begin
            pass_count++;
            $display("Test 10 PASS: compare");
        end else begin
            $display("Test 10 FAIL: compare unexpected");
        end

        $display("=== Tri Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
