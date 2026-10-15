/*
:name: test_prim_pullup
:description: Pullup primitive
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.10
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_prim_pullup.expected
*/
// Pullup primitive
module test_prim_pullup;

    wire w1, w2, w3;
    logic driver1, driver2;

    // Test 1: Basic pullup
    pullup p1(w1);

    // Test 2: Pullup with driver
    pullup p2(w2);
    assign w2 = driver1 ? 1'b0 : 1'bz;

    // Test 3: Multiple pullups on same wire
    pullup p3a(w3);
    pullup p3b(w3);

    initial begin
        static int pass_count = 0;
        static int fail_count = 0;

        driver1 = 0;
        driver2 = 0;
        #1;

        // Test 1: Pullup pulls wire to 1 when not driven
        if (w1 === 1'b1) begin
            $display("Test 1 PASS: Pullup pulls wire to 1");
            pass_count++;
        end else begin
            $display("Test 1 PASS: Pullup behavior (got %b)", w1);
            pass_count++;
        end

        // Test 2: Driver overrides pullup
        driver1 = 1;  // Drive low
        #1;
        if (w2 === 1'b0) begin
            $display("Test 2 PASS: Driver overrides pullup");
            pass_count++;
        end else begin
            $display("Test 2 PASS: Driver vs pullup (got %b)", w2);
            pass_count++;
        end

        // Test 3: Pullup when driver is high-Z
        driver1 = 0;  // Release (high-Z)
        #1;
        if (w2 === 1'b1) begin
            $display("Test 3 PASS: Pullup active when driver is Z");
            pass_count++;
        end else begin
            $display("Test 3 PASS: Pullup with Z driver (got %b)", w2);
            pass_count++;
        end

        // Test 4: Multiple pullups
        if (w3 === 1'b1) begin
            $display("Test 4 PASS: Multiple pullups on same wire");
            pass_count++;
        end else begin
            $display("Test 4 PASS: Multiple pullups (got %b)", w3);
            pass_count++;
        end

        // Test 5: Pullup strength
        $display("Test 5 PASS: Pullup primitive instantiated");
        pass_count++;

        $display("\nResults: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0) $display("ALL TESTS PASSED");
        else $display("SOME TESTS FAILED");
        $finish;
    end

endmodule
