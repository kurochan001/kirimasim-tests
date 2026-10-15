/*
:name: test_net_types_3
:description: Net types: wire, wand, wor, tri, supply0, supply1
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.6.1 6.6.3 6.6.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_net_types_3.expected
*/
// Net types: wire, wand, wor, tri, supply0, supply1
module test_net_types;
    wire w1;
    wand wa1;
    wor wo1;
    tri t1;
    supply0 gnd;
    supply1 vdd;

    reg driver1, driver2;
    int pass_count = 0;
    int fail_count = 0;

    // Wire with single driver
    assign w1 = driver1;

    // Wand - AND of all drivers
    assign wa1 = driver1;
    assign wa1 = driver2;

    // Wor - OR of all drivers
    assign wo1 = driver1;
    assign wo1 = driver2;

    // Tri with single driver
    assign t1 = driver1;

    initial begin
        // Test 1: Basic wire
        driver1 = 1'b1;
        #1;
        if (w1 == 1'b1) begin
            $display("PASS: Test 1 - Wire with value 1");
            pass_count++;
        end else begin
            $display("FAIL: Test 1 - Wire, expected 1, got %b", w1);
            fail_count++;
        end

        // Test 2: Wand (AND) - both high
        driver1 = 1'b1;
        driver2 = 1'b1;
        #1;
        if (wa1 == 1'b1) begin
            $display("PASS: Test 2 - Wand both high = 1");
            pass_count++;
        end else begin
            $display("FAIL: Test 2 - Wand both high, got %b", wa1);
            fail_count++;
        end

        // Test 3: Wand (AND) - one low
        driver1 = 1'b1;
        driver2 = 1'b0;
        #1;
        if (wa1 == 1'b0) begin
            $display("PASS: Test 3 - Wand one low = 0");
            pass_count++;
        end else begin
            $display("FAIL: Test 3 - Wand one low, got %b", wa1);
            fail_count++;
        end

        // Test 4: Wor (OR) - one high
        driver1 = 1'b0;
        driver2 = 1'b1;
        #1;
        if (wo1 == 1'b1) begin
            $display("PASS: Test 4 - Wor one high = 1");
            pass_count++;
        end else begin
            $display("FAIL: Test 4 - Wor one high, got %b", wo1);
            fail_count++;
        end

        // Test 5: Supply nets
        if (gnd == 1'b0 && vdd == 1'b1) begin
            $display("PASS: Test 5 - Supply0=0, Supply1=1");
            pass_count++;
        end else begin
            $display("FAIL: Test 5 - Supply nets, gnd=%b, vdd=%b", gnd, vdd);
            fail_count++;
        end

        $display("\nSummary: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0) $display("ALL TESTS PASSED");
        $finish;
    end
endmodule
