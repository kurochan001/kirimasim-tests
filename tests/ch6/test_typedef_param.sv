/*
:name: test_typedef_param
:description: Test: Parameterized typedef
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.18 6.20.2 8.25
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_typedef_param.expected
*/
// Test: Parameterized typedef
module test_typedef_param;
    int pass_count = 0;
    int fail_count = 0;

    // Parameterized width typedef via module parameter
    parameter int DATA_WIDTH = 16;
    parameter int ADDR_WIDTH = 8;

    typedef logic [DATA_WIDTH-1:0] data_t;
    typedef logic [ADDR_WIDTH-1:0] addr_t;

    // Parameterized struct typedef
    typedef struct packed {
        addr_t address;
        data_t data;
        logic valid;
    } transaction_t;

    // Parameterized array typedef
    parameter int DEPTH = 4;
    typedef data_t memory_t [DEPTH];

    // Parameterized class with typedef
    class container #(parameter int WIDTH = 8);
        typedef logic [WIDTH-1:0] element_t;
        element_t value;

        function new(element_t v = 0);
            value = v;
        endfunction

        function element_t get();
            return value;
        endfunction
    endclass

    // Typedef based on another typedef
    typedef data_t signed_data_t;  // Same width but can be used differently

    data_t my_data;
    addr_t my_addr;
    transaction_t txn;
    memory_t mem;
    container #(32) wide_cont;
    container #(8) narrow_cont;

    initial begin
        // Test 1: Basic parameterized typedef
        my_data = 16'hABCD;
        if (my_data == 16'hABCD && $bits(my_data) == DATA_WIDTH) begin
            $display("PASS: Parameterized data_t typedef");
            pass_count++;
        end else begin
            $display("FAIL: data_t - value=0x%04X, bits=%0d", my_data, $bits(my_data));
            fail_count++;
        end

        // Test 2: Different width typedef
        my_addr = 8'hFF;
        if (my_addr == 8'hFF && $bits(my_addr) == ADDR_WIDTH) begin
            $display("PASS: Parameterized addr_t typedef");
            pass_count++;
        end else begin
            $display("FAIL: addr_t - value=0x%02X, bits=%0d", my_addr, $bits(my_addr));
            fail_count++;
        end

        // Test 3: Parameterized struct typedef
        txn.address = 8'h80;
        txn.data = 16'h1234;
        txn.valid = 1;
        if (txn.address == 8'h80 && txn.data == 16'h1234 && txn.valid == 1) begin
            $display("PASS: Parameterized struct typedef");
            pass_count++;
        end else begin
            $display("FAIL: transaction_t - addr=0x%02X, data=0x%04X",
                     txn.address, txn.data);
            fail_count++;
        end

        // Test 4: Parameterized array typedef
        mem[0] = 16'h0001;
        mem[1] = 16'h0002;
        mem[2] = 16'h0003;
        mem[3] = 16'h0004;
        if (mem[0] == 16'h0001 && mem[3] == 16'h0004 && $size(mem) == DEPTH) begin
            $display("PASS: Parameterized array typedef");
            pass_count++;
        end else begin
            $display("FAIL: memory_t - [0]=0x%04X, size=%0d", mem[0], $size(mem));
            fail_count++;
        end

        // Test 5: Class with parameterized typedef (wide)
        wide_cont = new(32'hDEADBEEF);
        if (wide_cont.get() == 32'hDEADBEEF) begin
            $display("PASS: Class parameterized typedef (32-bit)");
            pass_count++;
        end else begin
            $display("FAIL: wide_cont - expected 0xDEADBEEF, got 0x%08X", wide_cont.get());
            fail_count++;
        end

        // Test 6: Class with parameterized typedef (narrow)
        narrow_cont = new(8'hAB);
        if (narrow_cont.get() == 8'hAB) begin
            $display("PASS: Class parameterized typedef (8-bit)");
            pass_count++;
        end else begin
            $display("FAIL: narrow_cont - expected 0xAB, got 0x%02X", narrow_cont.get());
            fail_count++;
        end

        // Test 7: Struct bits calculation
        if ($bits(txn) == DATA_WIDTH + ADDR_WIDTH + 1) begin
            $display("PASS: Struct typedef total bits = %0d", $bits(txn));
            pass_count++;
        end else begin
            $display("FAIL: txn bits - expected %0d, got %0d",
                     DATA_WIDTH + ADDR_WIDTH + 1, $bits(txn));
            fail_count++;
        end

        // Summary
        $display("Typedef param test: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0) $display("PASS: All typedef param tests passed");
        $finish;
    end
endmodule
