![](../../workflows/gds/badge.svg) ![](../../workflows/docs/badge.svg) ![](../../workflows/wokwi_test/badge.svg) ![](../../workflows/fpga/badge.svg)

# Tiny Tapeout Wokwi Project Template edited for PhBootCamp2026

/////Wowki Template was refactored for demo purposes

# Tiny Cyberdeck — Interactive 8-Bit Logic Core

Tiny Cyberdeck is an interactive digital logic circuit designed for Tiny Tapeout using Wokwi.

The project takes four user-controlled digital inputs and generates eight output signals using both direct and inverted logic. These outputs drive a 7-segment display, allowing the internal logic state to be visualized as different display patterns.

## Features

- 4 interactive digital inputs
- 8 Tiny Tapeout outputs
- Direct and complementary logic signals
- Four hardware NOT gates
- Real-time 7-segment visual feedback
- Fully implemented using the Tiny Tapeout Wokwi digital-design flow

## Logic

Each input controls one direct output and one complementary output:

| Input | Direct Output | Inverted Output |
|------|------|------|
| IN0 | OUT0 | OUT4 |
| IN1 | OUT1 | OUT5 |
| IN2 | OUT2 | OUT6 |
| IN3 | OUT3 | OUT7 |

The complementary outputs are generated using NOT gates:

`OUT4 = NOT(IN0)`  
`OUT5 = NOT(IN1)`  
`OUT6 = NOT(IN2)`  
`OUT7 = NOT(IN3)`

OUT0-OUT7 are connected to the A-G segments and decimal point of a common-cathode 7-segment display.

## Testing

Run the project in Wokwi and toggle SW1-SW4.

Each switch changes its corresponding direct output while simultaneously changing its complementary output. Different input combinations therefore create different patterns on the 7-segment display.

## Tiny Tapeout

This project was developed as part of the IEEE Philippine Bootcamp 2026 using the Tiny Tapeout Wokwi digital-design workflow.

The design has been verified through the repository's Wokwi test, GDS generation, FPGA build, and documentation workflows.
