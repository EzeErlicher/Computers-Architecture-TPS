import sys
import serial
import serial.tools.list_ports
import os
from typing import Optional
from compiler import RISCVCompiler

# Configuration
BAUDRATE = 19200      # Set baud rate for communication

COMMANDS = {
    'run_continuous':           0b00000001,
    'run_debug_stepwise':       0b00000010,
    'execute_next_instruction': 0b00000011,
    'upload_instructions':      0b00000100,
    'read_pipeline_state':      0b00000101,
    'end_instruction_stream':   0b00000110
}

def get_available_ports() -> list:
    """
    Get list of available serial ports.
    """
    ports = []
    for port, desc, hwid in serial.tools.list_ports.comports():
        ports.append((port, desc))
    return ports


def select_serial_port() -> Optional[str]:

    available_ports = get_available_ports()
    
    if not available_ports:
        print("\n" + "="*60)
        print("No serial ports detected")
        print("="*60)
        print("Please ensure your FPGA device is connected and drivers are installed.")
        return None
    
    print("\n" + "="*60)
    print("Available Serial Ports")
    print("="*60)
    
    for i, (port, desc) in enumerate(available_ports, 1):
        print(f"{i}. {port:6s} - {desc}")
    
    print(f"{len(available_ports) + 1}. Cancel")
    
    while True:
        try:
            choice = input(f"\nSelect port (1-{len(available_ports) + 1}): ").strip()
            choice_num = int(choice)
            
            if choice_num == len(available_ports) + 1:
                print("Connection cancelled.")
                return None
            
            if 1 <= choice_num <= len(available_ports):
                selected_port = available_ports[choice_num - 1][0]
                print(f"\n✓ Selected port: {selected_port}")
                return selected_port
            
            print(f"Invalid selection. Please enter 1-{len(available_ports) + 1}")
        except ValueError:
            print(f"Invalid input. Please enter a number 1-{len(available_ports) + 1}")


def exit_program(return_code=0, serial_port=None) -> None:
    """Close the serial port and exit the program."""
    print('Saliendo...')
    if serial_port is not None:
        serial_port.close()
    sys.exit(return_code)


def send_command(port, command_name) -> bool:
    if command_name not in COMMANDS:
        print(f"Error: Unknown command '{command_name}'")
        return False
    
    command_byte = COMMANDS[command_name]
    try:
        port.write(bytes([command_byte]))
        print(f"[SENT] {command_name}: 0x{command_byte:02X}")
        return True
    except serial.SerialException as e:
        print(f"Error sending command: {e}")
        return False


def send_instruction(port, instruction) -> bool:
    """Send a single 32-bit instruction as its 8-char hex representation."""
    instruction = instruction.strip().upper()
    
    if len(instruction) != 8:
        print(f"Error: Instruction must be 8 hex characters (4 bytes), got '{instruction}'")
        return False
    
    try:
        instruction_bytes = bytes.fromhex(instruction)
        port.write(instruction_bytes)
        print(f"[SENT] Instruction: 0x{instruction}")
        return True
    except ValueError:
        print(f"Error: Invalid hex instruction '{instruction}'")
        return False
    except serial.SerialException as e:
        print(f"Error sending instruction: {e}")
        return False


def upload_program(port, machine_code: list) -> bool:
    """Upload compiled machine code to the FPGA."""
    if not machine_code:
        print("Error: No machine code to upload")
        return False
    
    try:
        # Send upload instructions command
        if not send_command(port, 'upload_instructions'):
            return False
        
        # Send each instruction
        for i, code in enumerate(machine_code):
            instruction_hex = f"{code:08X}"
            if not send_instruction(port, instruction_hex):
                print(f"Failed to send instruction {i}")
                return False
        
        # Send end-of-stream marker
        if not send_command(port, 'end_instruction_stream'):
            return False
        
        print(f"\n[SUCCESS] Uploaded {len(machine_code)} instructions")
        return True
        
    except Exception as e:
        print(f"Error uploading program: {e}")
        return False


def compile_assembly_file(file_path: str) -> Optional[list]:

    if not os.path.exists(file_path):
        print(f"Error: File '{file_path}' not found")
        return None
    
    compiler = RISCVCompiler()
    machine_code = compiler.compile(file_path)
    
    if machine_code is None:
        return None
    
    print(f"[SUCCESS] Compiled {len(machine_code)} instructions")
    return machine_code


def upload_program_from_file(port, file_path) -> bool:

    if not os.path.exists(file_path):
        print(f"Error: File '{file_path}' not found")
        return False
    
    try:
        # Send upload instructions command
        if not send_command(port, 'upload_instructions'):
            return False
        
        # Read and send instructions
        with open(file_path, 'r') as f:
            instruction_count = 0
            for line in f:
                line = line.strip()
                
                # Skip empty lines and comments
                if not line or line.startswith('#'):
                    continue
                
                # Send the instruction
                if not send_instruction(port, line):
                    print(f"Failed to send instruction at line {instruction_count + 1}")
                    return False
                
                instruction_count += 1
        
        # Send end-of-stream marker
        if not send_command(port, 'end_instruction_stream'):
            return False
        
        print(f"\n[SUCCESS] Uploaded {instruction_count} instructions")
        return True
        
    except IOError as e:
        print(f"Error reading file: {e}")
        return False



def main():
    global serial_port
    serial_port = None
    
    try:
        # Select serial port
        selected_port = select_serial_port()
        if selected_port is None:
            sys.exit(0)
        
        # Initialize serial port
        try:
            serial_port = serial.Serial(selected_port, BAUDRATE, timeout=1)
            print(f"✓ Connected to {selected_port} at {BAUDRATE} baud")
        except serial.SerialException as e:
            print(f"\nError: Failed to open {selected_port}")
            print(f"Details: {e}")
            sys.exit(1)
        
        # Prompt for assembly file
        print("\n" + "="*60)
        print("FPGA Pipeline Interface - Program Compilation & Upload")
        print("="*60)
        
        while True:
            program_file = input("\nEnter the path to the assembly file (.asm or .s): ").strip()
            
            if not program_file:
                print("Error: Path cannot be empty")
                continue
            
            if not os.path.exists(program_file):
                print(f"Error: File not found: {program_file}")
                retry = input("Try again? (y/n): ").strip().lower()
                if retry != 'y':
                    exit_program(1, serial_port)
                continue
            
            # Compile the assembly file
            print(f"\nCompiling {program_file}...")
            machine_code = compile_assembly_file(program_file)
            
            if machine_code is None:
                print("Failed to compile program")
                exit_program(1, serial_port)
            
            assert machine_code is not None  # Type narrowing
            break
        
        # Upload the compiled program
        print("\nUploading program to FPGA...")
        if not upload_program(serial_port, machine_code):
            print("Failed to upload program")
            exit_program(1, serial_port)
        
        # Ask user what to do next
        print("\n" + "="*60)
        print("Program uploaded. Choose execution mode:")
        print("1. Run continuously")
        print("2. Run step-by-step (debug mode)")
        print("3. Exit")
        print("="*60)
        
        choice = input("\nSelect option (1-3): ").strip()
        
        if choice == '1':
            print("\nStarting continuous execution...")
            send_command(serial_port, 'run_continuous')
        elif choice == '2':
            print("\nStarting debug mode...")
            send_command(serial_port, 'run_debug_stepwise')
            
            # Allow step-by-step execution
            while True:
                step = input("Execute next instruction? (y/n): ").strip().lower()
                if step == 'y':
                    send_command(serial_port, 'execute_next_instruction')
                    # Optional: read pipeline state after each step
                    read = input("Read pipeline state? (y/n): ").strip().lower()
                    if read == 'y':
                        send_command(serial_port, 'read_pipeline_state')
                else:
                    break
        elif choice == '3':
            exit_program(0, serial_port)
        else:
            print("Invalid option")
            exit_program(1, serial_port)
        
        exit_program(0, serial_port)
        
    except Exception as e:
        print(f"Unexpected error: {e}")
        exit_program(1, serial_port)


if __name__ == "__main__":
    main()



