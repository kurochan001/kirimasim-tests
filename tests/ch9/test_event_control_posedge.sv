/*
:name: test_event_control_posedge
:description: Waiting for @(posedge clk) in an initial block (IEEE 1800-2023 Section 9.4.2)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.4.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_event_control_posedge.expected
*/
// Waiting for @(posedge clk) in an initial block (IEEE 1800-2023 Section 9.4.2)
module test_event_control_posedge;

    logic clk;
    logic [7:0] counter;
    logic [7:0] data;

    // Clock generation - toggle every time unit
    initial begin
        clk = 0;
        #1 clk = 1;
        #1 clk = 0;
        #1 clk = 1;
        #1 clk = 0;
        #1 clk = 1;
        #1 clk = 0;
    end

    // Counter incremented on positive edge of clock
    initial begin
        counter = 0;
        data = 0;

        $display("=== EVENT CONTROL TEST START ===");
        // clk is not printed: the other initial block sets it at time 0, in
        // no defined order with this block (4.7).
        $display("Time %0d: counter = %0d", $time, counter);

        // Wait for first positive edge
        @(posedge clk)
        counter = counter + 1;
        data = 10;
        $display("Time %0d: After first posedge - counter = %0d, data = %0d", $time, counter, data);

        // Wait for second positive edge
        @(posedge clk)
        counter = counter + 1;
        data = 20;
        $display("Time %0d: After second posedge - counter = %0d, data = %0d", $time, counter, data);

        // Wait for third positive edge
        @(posedge clk)
        counter = counter + 1;
        data = 30;
        $display("Time %0d: After third posedge - counter = %0d, data = %0d", $time, counter, data);

        $display("=== EVENT CONTROL TEST END ===");
        $display("Final: counter = %0d (expected 3)", counter);

        if (counter == 3) begin
            $display("SUCCESS: Event control @(posedge clk) works correctly!");
        end else begin
            $display("FAIL: Event control not working properly");
        end

        $finish;
    end

endmodule
