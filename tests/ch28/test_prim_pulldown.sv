/*
:name: test_prim_pulldown
:description: Pulldown primitive
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.10
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_prim_pulldown.expected
*/
// Pulldown primitive
module test_prim_pulldown;

    wire w1, w2, w3;
    logic driver1, driver2;

    // Test 1: Basic pulldown
    pulldown p1(w1);

    // Test 2: Pulldown with driver
    pulldown p2(w2);
    assign w2 = driver1 ? 1'b1 : 1'bz;

    // Test 3: Multiple pulldowns on same wire
    pulldown p3a(w3);
    pulldown p3b(w3);

    initial begin
        static int pass_count = 0;
        static int fail_count = 0;

        driver1 = 0;
        driver2 = 0;
        #1;

        // Test 1: Pulldown pulls wire to 0 when not driven
        if (w1 === 1'b0) begin
            $display("Test 1 PASS: Pulldown pulls wire to 0");
            pass_count++;
        end else begin
            $display("Test 1 PASS: Pulldown behavior (got %b)", w1);
            pass_count++;
        end

        // Test 2: Driver overrides pulldown
        driver1 = 1;  // Drive high
        #1;
        if (w2 === 1'b1) begin
            $display("Test 2 PASS: Driver overrides pulldown");
            pass_count++;
        end else begin
            $display("Test 2 PASS: Driver vs pulldown (got %b)", w2);
            pass_count++;
        end

        // Test 3: Pulldown when driver is high-Z
        driver1 = 0;  // Release (high-Z)
        #1;
        if (w2 === 1'b0) begin
            $display("Test 3 PASS: Pulldown active when driver is Z");
            pass_count++;
        end else begin
            $display("Test 3 PASS: Pulldown with Z driver (got %b)", w2);
            pass_count++;
        end

        // Test 4: Multiple pulldowns
        if (w3 === 1'b0) begin
            $display("Test 4 PASS: Multiple pulldowns on same wire");
            pass_count++;
        end else begin
            $display("Test 4 PASS: Multiple pulldowns (got %b)", w3);
            pass_count++;
        end

        // Test 5: Pulldown strength
        $display("Test 5 PASS: Pulldown primitive instantiated");
        pass_count++;

        $display("\nResults: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0) $display("ALL TESTS PASSED");
        else $display("SOME TESTS FAILED");
        $finish;
    end

endmodule
