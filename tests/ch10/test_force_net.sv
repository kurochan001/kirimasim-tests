/*
:name: test_force_net
:description: Force/release on nets
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.6.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_force_net.expected
*/
// Force/release on nets
module test_force_net;
    wire w1, w2;
    wire [7:0] bus;
    reg driver1, driver2;
    reg [7:0] bus_driver;
    int pass_count = 0;
    int fail_count = 0;

    assign w1 = driver1;
    assign w2 = driver2;
    assign bus = bus_driver;

    initial begin
        // Initialize drivers
        driver1 = 1'b0;
        driver2 = 1'b0;
        bus_driver = 8'h00;
        #1;

        // Test 1: Force net to high
        force w1 = 1'b1;
        #1;
        if (w1 == 1'b1) begin
            $display("PASS: Test 1 - Force net to high");
            pass_count++;
        end else begin
            $display("FAIL: Test 1 - Force net to high, got %b", w1);
            fail_count++;
        end

        // Test 2: Force overrides driver
        driver1 = 1'b0;  // Driver says low
        #1;
        if (w1 == 1'b1) begin  // But force keeps it high
            $display("PASS: Test 2 - Force overrides driver");
            pass_count++;
        end else begin
            $display("FAIL: Test 2 - Force should override driver");
            fail_count++;
        end

        // Test 3: Release net
        release w1;
        #1;
        if (w1 == 1'b0) begin  // Now driver takes over
            $display("PASS: Test 3 - Release net returns to driver");
            pass_count++;
        end else begin
            $display("FAIL: Test 3 - After release, got %b", w1);
            fail_count++;
        end

        // Test 4: Force bus (multi-bit)
        force bus = 8'hAB;
        #1;
        if (bus == 8'hAB) begin
            $display("PASS: Test 4 - Force multi-bit bus");
            pass_count++;
        end else begin
            $display("FAIL: Test 4 - Force bus, got %h", bus);
            fail_count++;
        end

        // Test 5: Release bus
        bus_driver = 8'hCD;
        release bus;
        #1;
        if (bus == 8'hCD) begin
            $display("PASS: Test 5 - Release bus returns to driver value");
            pass_count++;
        end else begin
            $display("FAIL: Test 5 - After release bus, got %h", bus);
            fail_count++;
        end

        $display("\nSummary: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0) $display("ALL TESTS PASSED");
        $finish;
    end
endmodule
