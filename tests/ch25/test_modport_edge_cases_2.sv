/*
:name: test_modport_edge_cases_2
:description: Modport edge cases
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.5 9.2.2
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_modport_edge_cases_2.expected
*/
// IEEE 1800-2023 §25.5: Modport edge cases
// Tests for interface modports

interface simple_if;
    logic clk;
    logic [7:0] data;
    logic valid;
    logic ready;
    
    modport master (
        input clk,
        output data, valid,
        input ready
    );
    
    modport slave (
        input clk,
        input data, valid,
        output ready
    );
    
    modport monitor (
        input clk, data, valid, ready
    );
endinterface

module producer(simple_if.master m);
    always @(posedge m.clk) begin
        if (m.ready) begin
            m.data <= m.data + 1;
            m.valid <= 1;
        end
    end
endmodule

module consumer(simple_if.slave s);
    always @(posedge s.clk) begin
        if (s.valid) begin
            s.ready <= 1;
        end
    end
endmodule

module test_modport_edge_cases_2;
    int pass_count = 0;
    int test_count = 0;

    simple_if intf();
    
    producer prod(intf.master);
    consumer cons(intf.slave);

    initial begin
        intf.clk = 0;
        intf.data = 0;
        intf.valid = 0;
        intf.ready = 1;
        #1;

        // Test 1: Initial values
        test_count++;
        if (intf.data == 0 && intf.valid == 0) begin
            pass_count++;
            $display("Test 1 PASS: Initial data=%0d valid=%b", intf.data, intf.valid);
        end else begin
            $display("Test 1 FAIL: Init unexpected");
        end

        // Test 2: Clock edge
        test_count++;
        intf.clk = 1;
        #1;
        intf.clk = 0;
        #1;
        // The producer saw ready=1 at the edge: data 0 -> 1, valid -> 1
        if (intf.data == 1 && intf.valid == 1) begin
            pass_count++;
            $display("Test 2 PASS: Clock edge");
        end else begin
            $display("Test 2 FAIL: data=%0d valid=%b", intf.data, intf.valid);
        end

        // Test 3: Data change
        test_count++;
        intf.clk = 1;
        #1;
        if (intf.data == 2) begin
            pass_count++;
            $display("Test 3 PASS: Data = %0d", intf.data);
        end else begin
            $display("Test 3 FAIL: Data unexpected");
        end

        // Test 4: Multiple cycles
        test_count++;
        for (int i = 0; i < 5; i++) begin
            intf.clk = 0;
            #1;
            intf.clk = 1;
            #1;
        end
        if (intf.data == 7) begin
            pass_count++;
            $display("Test 4 PASS: Multi cycles data=%0d", intf.data);
        end else begin
            $display("Test 4 FAIL: data=%0d", intf.data);
        end

        // Test 5: Ready signal
        test_count++;
        if (intf.ready == 1) begin
            pass_count++;
            $display("Test 5 PASS: Ready = %b", intf.ready);
        end else begin
            $display("Test 5 FAIL: Ready unexpected");
        end

        // Test 6: Valid signal
        test_count++;
        if (intf.valid == 1) begin
            pass_count++;
            $display("Test 6 PASS: Valid = %b", intf.valid);
        end else begin
            $display("Test 6 FAIL: valid=%b", intf.valid);
        end

        // Test 7: Interface access
        test_count++;
        intf.data = 8'hAA;
        #1;
        if (intf.data == 8'hAA) begin
            pass_count++;
            $display("Test 7 PASS: Direct access = %h", intf.data);
        end else begin
            $display("Test 7 FAIL: Access unexpected");
        end

        // Test 8: Reset sequence
        test_count++;
        intf.data = 0;
        intf.valid = 0;
        intf.ready = 0;
        #1;
        if (intf.data == 0 && intf.valid == 0 && intf.ready == 0) begin
            pass_count++;
            $display("Test 8 PASS: Reset done");
        end else begin
            $display("Test 8 FAIL: reset values");
        end

        // Test 9: Re-enable
        test_count++;
        intf.ready = 1;
        intf.clk = 0;
        #1;
        intf.clk = 1;
        #1;
        if (intf.data == 1 && intf.valid == 1) begin
            pass_count++;
            $display("Test 9 PASS: Re-enabled");
        end else begin
            $display("Test 9 FAIL: data=%0d valid=%b", intf.data, intf.valid);
        end

        // Test 10: Final state
        test_count++;
        if (intf.ready == 1) begin
            pass_count++;
            $display("Test 10 PASS: Final data=%0d valid=%b ready=%b", intf.data, intf.valid, intf.ready);
        end else begin
            $display("Test 10 FAIL: ready=%b", intf.ready);
        end

        $display("=== Modport Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
