module fp_multiplier_tb;

    // Instantiate the multiplier
    fp_multiplier uut (
        .clk(clk),
        .rst(rst),
        .a(a),
        .b(b),
        .result(result),
        .overflow(overflow),
        .underflow(underflow),
        .inf(inf),
        .nan(nan)
    );

    // Testbench signals
    reg clk;
    reg rst;
    reg [31:0] a, b;
    wire [31:0] result;
    wire overflow, underflow, inf, nan;

    // Clock generation
    always #5 clk = ~clk;

    // Test cases
    initial begin
        clk = 0;
        rst = 1;
        #10 rst = 0;

        // Test case 1: Normal multiplication
        a = 32'h40000000; // 2.0
        b = 32'h40400000; // 3.0
        #10;

        // Test case 2: Overflow
        a = 32'h7f7fffff; // Maximum positive number
        b = 32'h7f7fffff; // Maximum positive number
        #10;

        // Test case 3: Underflow
        a = 32'h00000001; // Smallest positive number
        b = 32'h00000001; // Smallest positive number
        #10;

        // Test case 4: Infinity
        a = 32'h7f800000; // Positive infinity
        b = 32'h40000000; // 2.0
        #10;

        // Test case 5: NaN
        a = 32'h7fc00000; // NaN
        b = 32'h40000000; // 2.0
        #10;

        // Test case 6: Denormalized numbers
        a = 32'h00000001; // Smallest positive denormalized number
        b = 32'h00000001; // Smallest positive denormalized number
        #10;

        // Test case 7: Special cases (e.g., zero, negative numbers)
        a = 32'h00000000; // Zero
        b = 32'h40000000; // 2.0
        #10;

        a = 32'h40000000; // 2.0
        b = 32'h00000000; // Zero
        #10;

        a = 32'hbf800000; // -2.0
        b = 32'h40000000; // 2.0
        #10;

        a = 32'h40000000; // 2.0
        b = 32'hbf800000; // -2.0
        #10;

        #10 $finish;
    end

endmodule

