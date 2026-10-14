/*
:name: test_real_types
:description: Chapter 6: Data types
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.12 6.12.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_real_types.expected
*/
// IEEE 1800-2023 Chapter 6: Data types
// §6.12 Real, shortreal, and realtime data types

module test_real_types;
    // §6.12 Real data types
    real r1, r2;
    shortreal sr;
    realtime rt;

    int test_count;
    int pass_count;

    initial begin
        test_count = 0;
        pass_count = 0;

        // Test 1: Real assignment
        r1 = 3.14159;
        test_count++;
        if (r1 > 3.14 && r1 < 3.15) pass_count++;
        else $display("FAIL: real - r1=%f", r1);

        // Test 2: Real arithmetic
        r1 = 10.0;
        r2 = 3.0;
        test_count++;
        if ((r1 / r2) > 3.33 && (r1 / r2) < 3.34) pass_count++;
        else $display("FAIL: real div - result=%f", r1/r2);

        // Test 3: Real negative
        r1 = -123.456;
        test_count++;
        if (r1 < 0) pass_count++;
        else $display("FAIL: real negative - r1=%f", r1);

        // Test 4: shortreal
        sr = 1.5;
        test_count++;
        if (sr > 1.4 && sr < 1.6) pass_count++;
        else $display("FAIL: shortreal - sr=%f", sr);

        // Test 5: realtime
        rt = 100.5;
        test_count++;
        if (rt > 100.0) pass_count++;
        else $display("FAIL: realtime - rt=%f", rt);

        // Test 6: Real to integer conversion
        r1 = 7.9;
        test_count++;
        if (int'(r1) == 8) pass_count++;  // rounds to the nearest integer (6.12.1)
        else $display("FAIL: real to int - result=%0d", int'(r1));

        $display("Chapter 6.12 Real Types: %0d/%0d tests passed", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("PASS");
        end else begin
            $display("FAIL");
        end
        $finish;
    end
endmodule
