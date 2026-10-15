/*
:name: test_tristate_z_values
:description: Tri-state gate Z value preservation
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.6 28.7
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_tristate_z_values.expected
*/
// IEEE 1800-2023 §28.6: Tri-state gate Z value preservation
// Tests that high-impedance (Z) output is preserved correctly

module test_tristate_z_values;
    int pass_count = 0;
    int test_count = 0;

    wire y_bufif0, y_bufif1, y_notif0, y_notif1;
    wire y_nmos, y_pmos;

    logic in_data;
    logic ctrl;

    // Tri-state buffers
    bufif0 bufif0_inst(y_bufif0, in_data, ctrl);
    bufif1 bufif1_inst(y_bufif1, in_data, ctrl);

    // Tri-state inverters
    notif0 notif0_inst(y_notif0, in_data, ctrl);
    notif1 notif1_inst(y_notif1, in_data, ctrl);

    // MOS switches
    nmos nmos_inst(y_nmos, in_data, ctrl);
    pmos pmos_inst(y_pmos, in_data, ctrl);

    initial begin
        // Test 1: BUFIF0 outputs Z when disabled (ctrl=1)
        test_count++;
        in_data = 1'b1;
        ctrl = 1'b1;  // Disable bufif0
        #1;
        if (y_bufif0 === 1'bz) begin
            pass_count++;
            $display("Test 1 PASS: BUFIF0 outputs Z when disabled (ctrl=1)");
        end else begin
            $display("Test 1 FAIL: BUFIF0 should output Z, got %b", y_bufif0);
        end

        // Test 2: BUFIF1 outputs Z when disabled (ctrl=0)
        test_count++;
        in_data = 1'b1;
        ctrl = 1'b0;  // Disable bufif1
        #1;
        if (y_bufif1 === 1'bz) begin
            pass_count++;
            $display("Test 2 PASS: BUFIF1 outputs Z when disabled (ctrl=0)");
        end else begin
            $display("Test 2 FAIL: BUFIF1 should output Z, got %b", y_bufif1);
        end

        // Test 3: NOTIF0 outputs Z when disabled (ctrl=1)
        test_count++;
        in_data = 1'b0;
        ctrl = 1'b1;  // Disable notif0
        #1;
        if (y_notif0 === 1'bz) begin
            pass_count++;
            $display("Test 3 PASS: NOTIF0 outputs Z when disabled (ctrl=1)");
        end else begin
            $display("Test 3 FAIL: NOTIF0 should output Z, got %b", y_notif0);
        end

        // Test 4: NOTIF1 outputs Z when disabled (ctrl=0)
        test_count++;
        in_data = 1'b0;
        ctrl = 1'b0;  // Disable notif1
        #1;
        if (y_notif1 === 1'bz) begin
            pass_count++;
            $display("Test 4 PASS: NOTIF1 outputs Z when disabled (ctrl=0)");
        end else begin
            $display("Test 4 FAIL: NOTIF1 should output Z, got %b", y_notif1);
        end

        // Test 5: NMOS outputs Z when gate=0
        test_count++;
        in_data = 1'b1;
        ctrl = 1'b0;  // Disable nmos
        #1;
        if (y_nmos === 1'bz) begin
            pass_count++;
            $display("Test 5 PASS: NMOS outputs Z when gate=0");
        end else begin
            $display("Test 5 FAIL: NMOS should output Z, got %b", y_nmos);
        end

        // Test 6: PMOS outputs Z when gate=1
        test_count++;
        in_data = 1'b1;
        ctrl = 1'b1;  // Disable pmos
        #1;
        if (y_pmos === 1'bz) begin
            pass_count++;
            $display("Test 6 PASS: PMOS outputs Z when gate=1");
        end else begin
            $display("Test 6 FAIL: PMOS should output Z, got %b", y_pmos);
        end

        $display("=== Tri-State Z Value Test Results ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
