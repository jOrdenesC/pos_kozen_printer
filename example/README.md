# pos_kozen_printer Example

This is a sample application that demonstrates how to use the `pos_kozen_printer` plugin.

## Features demonstrated

- ✅ Printer connection and disconnection
- ✅ Print sample receipt with logo
- ✅ Receipt with header, items in columns, and total
- ✅ Image printing (PNG)
- ✅ Printer status verification
- ✅ Error handling

## How to run

1. Make sure you have a TUU/Haulmer POS PRO2 device
2. Run:
   ```bash
   flutter run
   ```

## Basic usage

The app shows a simple interface with:

1. **Status panel**: Shows if the printer is connected
2. **Print sample receipt**: Prints a complete formatted receipt with logo

## Important notes

- The printer must be connected before printing
- Printing not supported with screen locked
- The printer may overheat with continuous use

