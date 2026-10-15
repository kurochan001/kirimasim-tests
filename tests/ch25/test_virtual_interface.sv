/*
:name: test_virtual_interface
:description: Virtual Interface Tests
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.9 8.4
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_virtual_interface.expected
*/
// IEEE 1800-2023 Section 25.9 - Virtual Interface Tests
// Tests: virtual interface declaration, assignment, signal access

interface simple_if;
    logic [7:0] data;
    logic valid;
    logic ready;

    modport driver (output data, valid, input ready);
    modport monitor (input data, valid, ready);
endinterface

class Monitor;
    virtual simple_if vif;  // Use full interface (not modport) for simpler access

    function new(virtual simple_if vif_in);
        this.vif = vif_in;
    endfunction

    function logic [7:0] read_data();
        return vif.data;
    endfunction

    function logic is_valid();
        return vif.valid;
    endfunction

    function logic is_ready();
        return vif.ready;
    endfunction
endclass

module test_virtual_interface;
    int pass_count = 0;
    int fail_count = 0;

    simple_if sif();

    initial begin
        Monitor mon;
        virtual simple_if vif_local;

        $display("=== IEEE 1800-2023 Virtual Interface Tests ===");

        // Initialize interface directly
        sif.data = 8'h00;
        sif.valid = 0;
        sif.ready = 1;

        // Test 1: Virtual interface variable declaration
        $display("Test 1: Virtual interface declaration");
        vif_local = sif;
        if (vif_local != null) begin
            $display("Test 1 PASS");
            pass_count++;
        end else begin
            $display("Test 1 FAIL");
            fail_count++;
        end

        // Test 2: Virtual interface in class
        $display("Test 2: Virtual interface in class");
        mon = new(sif);
        if (mon != null) begin
            $display("Test 2 PASS");
            pass_count++;
        end else begin
            $display("Test 2 FAIL");
            fail_count++;
        end

        // Test 3: Read through class virtual interface
        $display("Test 3: Read initial value through vif");
        if (mon.read_data() == 8'h00) begin
            $display("Test 3 PASS");
            pass_count++;
        end else begin
            $display("Test 3 FAIL");
            fail_count++;
        end

        // Test 4: Direct interface write, read via class
        $display("Test 4: Write direct, read via class");
        sif.data = 8'hAB;
        #1;
        if (mon.read_data() == 8'hAB) begin
            $display("Test 4 PASS");
            pass_count++;
        end else begin
            $display("Test 4 FAIL: mon.read_data()=%h", mon.read_data());
            fail_count++;
        end

        // Test 5: Valid signal through vif
        $display("Test 5: Valid signal through vif");
        sif.valid = 1;
        #1;
        if (mon.is_valid() == 1) begin
            $display("Test 5 PASS");
            pass_count++;
        end else begin
            $display("Test 5 FAIL");
            fail_count++;
        end

        // Test 6: Ready signal check
        $display("Test 6: Ready signal through vif");
        if (mon.is_ready() == 1) begin
            $display("Test 6 PASS");
            pass_count++;
        end else begin
            $display("Test 6 FAIL");
            fail_count++;
        end

        // Summary
        #1;
        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");
        $finish;
    end
endmodule
