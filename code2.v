module fp_multiplier_pipelined(
    input clk,
    input rst,
    input [31:0] a,
    input [31:0] b,
    output [31:0] result,
    output reg overflow,
    output reg underflow,
    output reg inf,
    output reg nan
);

    // Parameters
    parameter EXP_WIDTH = 8;
    parameter MANTISSA_WIDTH = 23;
    parameter ROUNDING_MODE = 0; // 0: round to nearest, 1: round towards zero, 2: round towards +inf, 3: round towards -inf

    // Pipeline stages
    reg [31:0] stage1_a, stage1_b;
    reg [EXP_WIDTH-1:0] stage2_exp_result;
    reg [MANTISSA_WIDTH-1:0] stage2_mantissa_result;
    reg [EXP_WIDTH-1:0] stage3_exp_result;
    reg [MANTISSA_WIDTH-1:0] stage3_mantissa_result;
    reg [MANTISSA_WIDTH-1:0] stage4_mantissa_result;
    reg [EXP_WIDTH-1:0] stage4_exp_result;

    // Custom hardware units
    wire [2*MANTISSA_WIDTH-1:0] mantissa_product;
    wire [EXP_WIDTH-1:0] exp_sum;

    // Mantissa multiplier (Wallace tree or Booth's algorithm)
    multiplier #(MANTISSA_WIDTH) mantissa_multiplier (
        .a(stage1_a[22:0]),
        .b(stage1_b[22:0]),
        .product(mantissa_product)
    );

    // Exponent adder (carry-lookahead adder)
    adder #(EXP_WIDTH) exponent_adder (
        .a(stage1_a[30:23]),
        .b(stage1_b[30:23]),
        .sum(exp_sum)
    );

    // Stage 2: Mantissa multiplication
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            stage2_mantissa_result <= 0;
        end else begin
            stage2_mantissa_result <= mantissa_product;
        end
    end

    // Stage 3: Exponent addition and normalization
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            stage3_exp_result <= 0;
            stage3_mantissa_result <= 0;
        end else begin
            stage3_exp_result <= exp_sum - (EXP_WIDTH - 1); // Adjust for normalization
            stage3_mantissa_result <= stage2_mantissa_result;
        end
    end

    // Stage 4: Rounding and normalization (adjust as needed)
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            stage4_mantissa_result <= 0;
            stage4_exp_result <= 0;
        end else begin
            // ... rounding logic
            stage4_mantissa_result <= stage3_mantissa_result;
            stage4_exp_result <= stage3_exp_result;
        end
    end

    // Assemble result
    always @(*) begin
        if (inf) begin
            result <= {sign_result, 2**EXP_WIDTH - 1, 0};
        end else if (nan) begin
            result <= {1'b1, 2**EXP_WIDTH - 1, 0};
        end else begin
            result[31] <= sign_result;
            result[30:23] <= stage4_exp_result;
            result[22:0] <= stage4_mantissa_result;
        end
    end

endmodule
