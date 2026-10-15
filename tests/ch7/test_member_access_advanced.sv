/*
:name: test_member_access_advanced
:description: Test for advanced member access patterns
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.2 7.3 8.5
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_member_access_advanced.expected
*/
// Test for advanced member access patterns
// IEEE 1800-2023 §7.2, §7.3 and §8.5 (struct, union and class member access)

module test_member_access_advanced;
    // Struct definitions
    typedef struct packed {
        logic [7:0] high;
        logic [7:0] low;
    } word_t;

    typedef struct {
        int x;
        int y;
        word_t data;
    } point_t;

    // Union definition
    typedef union packed {
        logic [31:0] word;
        logic [3:0][7:0] bytes;
    } data_union_t;

    // Variables
    point_t pt;
    word_t wd;
    data_union_t du;
    int pass_count = 0;
    int test_count = 0;

    // Class with nested struct
    class Container;
        point_t pt;
        int arr[3];
        
        function new();
            pt.x = 0;
            pt.y = 0;
            arr[0] = 0;
            arr[1] = 0;
            arr[2] = 0;
        endfunction
        
        function void setPoint(int x, int y);
            pt.x = x;
            pt.y = y;
        endfunction
        
        function int getX();
            return pt.x;
        endfunction
    endclass

    Container c;

    initial begin
        // Test 1: Simple struct member access
        test_count++;
        pt.x = 10;
        pt.y = 20;
        if (pt.x == 10 && pt.y == 20) begin
            $display("Test 1: Struct member access PASS");
            pass_count++;
        end else begin
            $display("Test 1: Struct member access FAIL");
        end

        // Test 2: Nested struct member
        test_count++;
        pt.data.high = 8'hAB;
        pt.data.low = 8'hCD;
        if (pt.data.high == 8'hAB) begin
            $display("Test 2: Nested struct member PASS");
            pass_count++;
        end else begin
            $display("Test 2: Nested struct member FAIL");
        end

        // Test 3: Packed union access
        test_count++;
        du.word = 32'hDEADBEEF;
        if (du.bytes[0] == 8'hEF) begin
            $display("Test 3: Union byte access PASS");
            pass_count++;
        end else begin
            $display("Test 3: Union byte access FAIL");
        end

        // Test 4: Union member write
        test_count++;
        du.bytes[3] = 8'hCA;
        du.bytes[2] = 8'hFE;
        if (du.word[31:16] == 16'hCAFE) begin
            $display("Test 4: Union member write PASS");
            pass_count++;
        end else begin
            $display("Test 4: Union member write FAIL");
        end

        // Test 5: Class member access
        test_count++;
        c = new();
        c.pt.x = 100;
        c.pt.y = 200;
        if (c.pt.x == 100) begin
            $display("Test 5: Class member access PASS");
            pass_count++;
        end else begin
            $display("Test 5: Class member access FAIL");
        end

        // Test 6: Class method with member access
        test_count++;
        c.setPoint(50, 60);
        if (c.getX() == 50 && c.pt.x == 50 && c.pt.y == 60) begin
            $display("Test 6: Class method access PASS");
            pass_count++;
        end else begin
            $display("Test 6: Class method access - expected 50, got %0d FAIL", c.pt.x);
        end

        // Test 7: Class array member
        test_count++;
        c.arr[0] = 1;
        c.arr[1] = 2;
        c.arr[2] = 3;
        if (c.arr[1] == 2) begin
            $display("Test 7: Class array member PASS");
            pass_count++;
        end else begin
            $display("Test 7: Class array member FAIL");
        end

        // Test 8: Packed struct width
        test_count++;
        wd.high = 8'hFF;
        wd.low = 8'h00;
        if ($bits(wd) == 16) begin
            $display("Test 8: Packed struct $bits = %0d PASS", $bits(wd));
            pass_count++;
        end else begin
            $display("Test 8: Packed struct $bits = %0d FAIL", $bits(wd));
        end

        // Report
        if (pass_count == test_count) begin
            $display("TEST PASSED: %0d/%0d tests passed", pass_count, test_count);
        end else begin
            $display("TEST FAILED: %0d/%0d tests passed", pass_count, test_count);
        end

        $finish;
    end
endmodule
