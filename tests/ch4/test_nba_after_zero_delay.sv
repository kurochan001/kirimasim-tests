/*
:name: test_nba_after_zero_delay
:description: A process resumed after #0 runs before the nonblocking assignments of the same time slot (IEEE 1800-2023 Sections 4.4.2.3, 4.4.2.4 and 10.4.2)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.4.2.3 4.4.2.4 10.4.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_nba_after_zero_delay.expected
*/
// Active, Inactive and NBA regions: after #0 the process resumes in the
// Inactive region, before the NBA region of the same time slot
// (IEEE 1800-2023 Sections 4.4.2.3, 4.4.2.4 and 10.4.2)
module test_nba_after_zero_delay;

    logic [7:0] blocking_val;
    logic [7:0] nonblocking_val;

    initial begin
        $display("=== NBA After Zero Delay Test ===");

        // Test 1: Blocking assignment (Active region)
        blocking_val = 8'hAA;
        $display("After blocking: blocking_val = %h", blocking_val);

        // Test 2: Non-blocking assignment (NBA region)
        nonblocking_val <= 8'hBB;
        $display("After NBA schedule: nonblocking_val = %h (should be old value)", nonblocking_val);

        // Wait for delta cycle
        #0;
        $display("After #0 delay: nonblocking_val = %h (NBA not applied yet)", nonblocking_val);

        // Test ordering
        #1;
        blocking_val = 8'h11;
        nonblocking_val <= blocking_val;  // Should get 11

        #1;
        $display("Final: blocking=%h, nonblocking=%h", blocking_val, nonblocking_val);

        if (nonblocking_val == 8'h11) begin
            $display("PASS: LRM ordering correct");
        end else begin
            $display("FAIL: LRM ordering incorrect");
        end

        $finish;
    end

endmodule
