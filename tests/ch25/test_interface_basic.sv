/*
:name: test_interface_basic
:description: Interface Basic Tests
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.3 25.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_interface_basic.expected
*/
// IEEE 1800-2023 Section 25 - Interface Basic Tests
// Tests: Interface instantiation, signal access

interface simple_if;
    logic [7:0] data;
    logic valid;
    logic ready;
endinterface

module producer(simple_if sif);
    initial begin
        sif.data = 8'h00;
        sif.valid = 0;
    end
endmodule

module consumer(simple_if sif);
    initial begin
        sif.ready = 1;
    end
endmodule

module test_interface_basic;
    int pass_count = 0;
    int fail_count = 0;

    simple_if bus();

    producer prod(bus);
    consumer cons(bus);

    initial begin
        $display("=== IEEE 1800-2023 Interface Basic Tests ===");

        #1;  // Allow initial blocks to execute

        // Test 1: Interface instantiation
        $display("Test 1: Interface instantiation");
        if (bus.valid == 0 && bus.ready == 1) begin
            $display("Test 1 PASS: interface created");
            pass_count++;
        end else begin
            $display("Test 1 FAIL: valid=%b ready=%b", bus.valid, bus.ready);
            fail_count++;
        end

        // Test 2: Write data signal
        $display("Test 2: Write data signal");
        bus.data = 8'hAB;
        #1;
        if (bus.data == 8'hAB) begin
            $display("Test 2 PASS: data=%h", bus.data);
            pass_count++;
        end else begin
            $display("Test 2 FAIL");
            fail_count++;
        end

        // Test 3: Write valid signal
        $display("Test 3: Write valid signal");
        bus.valid = 1;
        #1;
        if (bus.valid == 1) begin
            $display("Test 3 PASS: valid=%b", bus.valid);
            pass_count++;
        end else begin
            $display("Test 3 FAIL");
            fail_count++;
        end

        // Test 4: Read ready signal
        $display("Test 4: Read ready signal");
        if (bus.ready == 1) begin
            $display("Test 4 PASS: ready=%b", bus.ready);
            pass_count++;
        end else begin
            $display("Test 4 FAIL");
            fail_count++;
        end

        // Test 5: Modify data
        $display("Test 5: Modify data");
        bus.data = 8'hCD;
        #1;
        if (bus.data == 8'hCD) begin
            $display("Test 5 PASS: data=%h", bus.data);
            pass_count++;
        end else begin
            $display("Test 5 FAIL");
            fail_count++;
        end

        // Test 6: Clear valid
        $display("Test 6: Clear valid");
        bus.valid = 0;
        #1;
        if (bus.valid == 0) begin
            $display("Test 6 PASS: valid=%b", bus.valid);
            pass_count++;
        end else begin
            $display("Test 6 FAIL");
            fail_count++;
        end

        // Test 7: Multiple signal update
        $display("Test 7: Multiple signal update");
        bus.data = 8'hEF;
        bus.valid = 1;
        bus.ready = 0;
        #1;
        if (bus.data == 8'hEF && bus.valid == 1 && bus.ready == 0) begin
            $display("Test 7 PASS: data=%h valid=%b ready=%b", bus.data, bus.valid, bus.ready);
            pass_count++;
        end else begin
            $display("Test 7 FAIL");
            fail_count++;
        end

        // Test 8: Final state
        $display("Test 8: Final state");
        bus.data = 8'h00;
        bus.valid = 0;
        bus.ready = 1;
        #1;
        if (bus.data == 8'h00) begin
            $display("Test 8 PASS: reset complete");
            pass_count++;
        end else begin
            $display("Test 8 FAIL");
            fail_count++;
        end

        // Summary
        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");
        $finish;
    end
endmodule
