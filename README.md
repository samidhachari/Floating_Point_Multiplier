# Floating_Point_Multiplier
Designed and implemented a pipelined floating-point multiplier in Verilog HDL.  Utilized advanced optimization techniques like pipelining, custom hardware units (e.g., carry-lookahead adder), and rounding logic for improved performance. Ensured robust handling of special cases (NaN, infinity, denormalized numbers).


Normal Version:

This Verilog code implements a sequential floating-point multiplier that performs the following steps:

Extracts the sign, exponent, and mantissa fields from the input operands.
Multiplies the mantissas using a standard multiplication algorithm.
Adds the exponents and adjusts for normalization.
Rounds the result according to the specified rounding mode.
Handles special cases like NaN, infinity, and denormalized numbers.
The normal version is suitable for smaller or less performance-critical applications.

Pipelined Version:

This Verilog code implements a pipelined floating-point multiplier that improves performance by dividing the multiplication process into stages and allowing multiple operations to be processed simultaneously. The pipelined version utilizes custom hardware units, such as a Wallace tree multiplier for the mantissa multiplication and a carry-lookahead adder for the exponent addition.

The pipeline stages typically include:

Component Extraction: Extracts the sign, exponent, and mantissa fields from the input operands.
Mantissa Multiplication: Multiplies the mantissas using a custom hardware unit.
Exponent Addition and Normalization: Adds the exponents and adjusts for normalization.
Rounding: Rounds the result according to the specified rounding mode.
The pipelined version is well-suited for applications that require high-performance floating-point multiplication, such as digital signal processing, scientific computing, and graphics processing.

Key Differences:

Performance: The pipelined version generally offers significantly better performance due to its ability to process multiple operations in parallel.
Complexity: The pipelined version is more complex to design and implement, as it requires careful synchronization and control logic.
Area: The pipelined version may require more hardware resources due to the additional registers and control logic.
