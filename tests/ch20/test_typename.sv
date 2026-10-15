/*
:name: test_typename
:description: Test for $typename system function
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.6.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_typename.expected
*/
// Test for $typename system function (20.6.1).
// The spacing of packed ranges in the result is not settled by the examples in
// 20.6.1, so those results are compared with $typename of an equivalent type.
module test_typename;
    logic [7:0] logic_var;
    reg [31:0] reg_var;
    integer int_var;
    real real_var;
    string str_var;
    bit [15:0] bit_var;

    typedef struct packed {
        logic [7:0] field1;
        logic [7:0] field2;
    } my_struct_t;

    my_struct_t struct_var;

    integer pass_count;
    string type_str;

    initial begin
        pass_count = 0;

        // Test 1: $typename of logic
        type_str = $typename(logic_var);
        if (type_str == $typename(logic [7:0]) && type_str != $typename(bit [7:0])) begin
            $display("Test 1: $typename logic - PASS");
            pass_count = pass_count + 1;
        end else begin
            $display("Test 1: $typename logic - FAIL");
        end

        // Test 2: $typename of integer
        type_str = $typename(int_var);
        if (type_str == "integer") begin
            $display("Test 2: $typename integer - PASS");
            pass_count = pass_count + 1;
        end else begin
            $display("Test 2: $typename integer - FAIL");
        end

        // Test 3: $typename of real
        type_str = $typename(real_var);
        if (type_str == "real") begin
            $display("Test 3: $typename real - PASS");
            pass_count = pass_count + 1;
        end else begin
            $display("Test 3: $typename real - FAIL");
        end

        // Test 4: $typename of string
        type_str = $typename(str_var);
        if (type_str == "string") begin
            $display("Test 4: $typename string - PASS");
            pass_count = pass_count + 1;
        end else begin
            $display("Test 4: $typename string - FAIL");
        end

        // Test 5: $typename of typedef struct
        type_str = $typename(struct_var);
        if (type_str == $typename(my_struct_t) && type_str != $typename(logic [15:0])) begin
            $display("Test 5: $typename struct - PASS");
            pass_count = pass_count + 1;
        end else begin
            $display("Test 5: $typename struct - FAIL");
        end

        if (pass_count == 5)
            $display("All typename tests PASS");
        else
            $display("Some tests FAIL: %0d/5 passed", pass_count);

        $finish;
    end
endmodule
