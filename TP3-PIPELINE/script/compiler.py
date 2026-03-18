import sys
import os
from typing import Optional

class RISCVCompiler:
    # ==================== DATA STRUCTURES ====================
    # Register mapping: x0-x31 + ABI names
    REGISTERS = {**{f'x{i}': i for i in range(32)}, **{
        'zero': 0, 'ra': 1, 'sp': 2, 'gp': 3, 'tp': 4,
        't0': 5, 't1': 6, 't2': 7, 's0': 8, 'fp': 8, 's1': 9,
        'a0': 10, 'a1': 11, 'a2': 12, 'a3': 13, 'a4': 14, 'a5': 15,
        'a6': 16, 'a7': 17, 's2': 18, 's3': 19, 's4': 20, 's5': 21,
        's6': 22, 's7': 23, 's8': 24, 's9': 25, 's10': 26, 's11': 27,
        't3': 28, 't4': 29, 't5': 30, 't6': 31,
    }}
    
    # Instruction type mapping
    INSTRUCTION_TYPES = {
        'R': ['add', 'sub', 'sll', 'srl', 'sra', 'and', 'or', 'xor', 'slt', 'sltu'],
        'I': ['addi', 'andi', 'ori', 'xori', 'slti', 'sltiu'],
        'I_SHIFT': ['slli', 'srli', 'srai'],
        'I_LOAD': ['jalr', 'lb', 'lh', 'lw', 'lbu', 'lhu'],
        'S': ['sb', 'sh', 'sw'],
        'B': ['beq', 'bne'],
        'U': ['lui'],
        'J': ['jal'],
    }
    
    # Instruction specifications: opcode, funct3, [funct7]
    INSTRUCTION_SPECS = {
        'add': (0b110011, 0b000, 0b0000000), 'sub': (0b110011, 0b000, 0b0100000), 'sll': (0b110011, 0b001, 0b0000000),
        'srl': (0b110011, 0b101, 0b0000000), 'sra': (0b110011, 0b101, 0b0100000), 'and': (0b110011, 0b111, 0b0000000),
        'or':  (0b110011, 0b110, 0b0000000), 'xor': (0b110011, 0b100, 0b0000000), 'slt': (0b110011, 0b010, 0b0000000),
        'sltu': (0b110011, 0b011, 0b0000000),
        'addi': (0b010011, 0b000), 'andi': (0b010011, 0b111), 'ori': (0b010011, 0b110),
        'xori': (0b010011, 0b100), 'slti': (0b010011, 0b010), 'sltiu': (0b010011, 0b011),
        'slli': (0b010011, 0b001, 0b0000000), 'srli': (0b010011, 0b101, 0b0000000), 'srai': (0b010011, 0b101, 0b0100000),
        'jalr': (0b1100111, 0b000), 'lb': (0b0000011, 0b000), 'lh': (0b0000011, 0b001),
        'lw': (0b0000011, 0b010), 'lbu': (0b0000011, 0b100), 'lhu': (0b0000011, 0b101),
        'sb': (0b0100011, 0b000), 'sh': (0b0100011, 0b001), 'sw': (0b0100011, 0b010),
        'beq': (0b1100011, 0b000), 'bne': (0b1100011, 0b001),
        'lui': (0b0110111,), 'jal': (0b1101111,),
    }
    
    # ==================== INITIALIZATION ====================
    def __init__(self):
        self.assemblers = {
            'R': self._assemble_r_type,
            'I': self._assemble_i_type,
            'I_SHIFT': self._assemble_i_shift_type,
            'I_LOAD': self._assemble_load_type,
            'S': self._assemble_s_type,
            'B': self._assemble_b_type,
            'U': self._assemble_u_type,
            'J': self._assemble_j_type,
        }
    
    # ==================== AUXILIARY METHODS ====================
    def _parse_register(self, reg_str: str) -> int:
        reg = self.REGISTERS.get(reg_str.strip().lower())
        if reg is None:
            raise ValueError(f"Unknown register: {reg_str}")
        return reg
    
    def _parse_immediate(self, imm_str: str) -> int:
        imm_str = imm_str.strip()
        try:
            return int(imm_str, 16) if imm_str.lower().startswith('0x') else int(imm_str)
        except ValueError:
            raise ValueError(f"Invalid immediate: {imm_str}")
    
    def _sign_extend(self, value: int, bits: int) -> int:
        if value & (1 << (bits - 1)):
            value |= -(1 << bits)
        return value & 0xFFFFFFFF
    
    def _validate_regs(self, *regs: int) -> None:
        for reg in regs:
            if not (0 <= reg <= 31):
                raise ValueError(f"Register {reg} out of range [0, 31]")
    
    def _get_instruction_type(self, instr_name: str) -> Optional[str]:
        for itype, instrs in self.INSTRUCTION_TYPES.items():
            if instr_name in instrs:
                return itype
        return None
    
    def _parse_operands(self, line: str, count: int) -> list:
        """Parse comma-separated operands from instruction line."""

        parts = line.split(None, 1)
        if len(parts) < 2:
            raise ValueError(f"Expected operands in: {line}")
        
        operand_str = parts[1].strip()
        operands = [op.strip() for op in operand_str.split(',')]

        if len(operands) != count:
            raise ValueError(f"Expected {count} operands, got {len(operands)}")
        
        return operands
    
    # ==================== INSTRUCTION ASSEMBLY METHODS ====================
    def _assemble_r_type(self, instr_name: str, line: str, spec: tuple) -> int:
        """Assemble and encode R-type: rd, rs1, rs2"""
        operands = self._parse_operands(line, 3)
        rd, rs1, rs2 = (self._parse_register(operands[0]), 
                        self._parse_register(operands[1]), 
                        self._parse_register(operands[2]))
        self._validate_regs(rd, rs1, rs2)
        opcode, funct3, funct7 = spec
        return ((funct7 << 25) | (rs2 << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | opcode) & 0xFFFFFFFF
    
    def _assemble_i_type(self, instr_name: str, line: str, spec: tuple) -> int:
        """Assemble and encode I-type: rd, rs1, imm"""
        operands = self._parse_operands(line, 3)
        rd, rs1, imm = (self._parse_register(operands[0]), 
                        self._parse_register(operands[1]), 
                        self._parse_immediate(operands[2]))
        self._validate_regs(rd, rs1)
        opcode, funct3 = spec
        imm = self._sign_extend(imm, 12) & 0xFFF
        return ((imm << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | opcode) & 0xFFFFFFFF
    
    def _assemble_i_shift_type(self, instr_name: str, line: str, spec: tuple) -> int:
        """Assemble and encode I-shift: rd, rs1, shamt"""
        operands = self._parse_operands(line, 3)
        rd, rs1 = (self._parse_register(operands[0]), 
                   self._parse_register(operands[1]))
        shamt = int(operands[2].strip())
        self._validate_regs(rd, rs1)
        if not (0 <= shamt <= 31):
            raise ValueError(f"Shift amount {shamt} out of range [0, 31]")
        opcode, funct3, funct7 = spec
        return ((funct7 << 25) | (shamt << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | opcode) & 0xFFFFFFFF
    
    def _assemble_load_type(self, instr_name: str, line: str, spec: tuple) -> int:
        """Assemble and encode I-load: rd, offset(rs1)"""
        parts = line.split(None, 1)
        if len(parts) < 2:
            raise ValueError(f"Expected operands in: {line}")
        operand_str = parts[1].strip()
        
        if '(' not in operand_str or ')' not in operand_str:
            raise ValueError(f"Invalid load operand format: {operand_str}")
        
        rd_str, mem_str = operand_str.split(',', 1)
        rd = self._parse_register(rd_str.strip())
        
        mem_str = mem_str.strip()
        offset_str = mem_str[:mem_str.index('(')].strip()
        rs1_str = mem_str[mem_str.index('(') + 1:mem_str.index(')')].strip()
        
        rs1 = self._parse_register(rs1_str)
        offset = self._parse_immediate(offset_str)
        
        self._validate_regs(rd, rs1)
        opcode, funct3 = spec
        offset = self._sign_extend(offset, 12) & 0xFFF
        return ((offset << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | opcode) & 0xFFFFFFFF

    def _assemble_s_type(self, instr_name: str, line: str, spec: tuple) -> int:
        """Assemble and encode S-type: rs2, offset(rs1)"""
        parts = line.split(None, 1)
        if len(parts) < 2:
            raise ValueError(f"Expected operands in: {line}")
        operand_str = parts[1].strip()
        
        if '(' not in operand_str or ')' not in operand_str:
            raise ValueError(f"Invalid store operand format: {operand_str}")
        
        rs2_str, mem_str = operand_str.split(',', 1)
        rs2 = self._parse_register(rs2_str.strip())
        
        mem_str = mem_str.strip()
        offset_str = mem_str[:mem_str.index('(')].strip()
        rs1_str = mem_str[mem_str.index('(') + 1:mem_str.index(')')].strip()
        
        rs1 = self._parse_register(rs1_str)
        imm = self._parse_immediate(offset_str)
        
        self._validate_regs(rs2, rs1)
        opcode, funct3 = spec
        imm = self._sign_extend(imm, 12)
        return (((imm >> 5) << 25) | (rs2 << 20) | (rs1 << 15) | (funct3 << 12) | ((imm & 0x1F) << 7) | opcode) & 0xFFFFFFFF

    def _assemble_b_type(self, instr_name: str, line: str, spec: tuple) -> int:
        """Assemble and encode B-type: rs1, rs2, offset"""
        operands = self._parse_operands(line, 3)
        rs1, rs2, offset = (self._parse_register(operands[0]), 
                            self._parse_register(operands[1]), 
                            self._parse_immediate(operands[2]))
        self._validate_regs(rs1, rs2)
        opcode, funct3 = spec
        imm = self._sign_extend(offset, 13)
        return (((imm & 0x1000) << 19) | (((imm >> 5) & 0x3F) << 25) | (rs2 << 20) | 
                (rs1 << 15) | (funct3 << 12) | (((imm >> 1) & 0xF) << 8) | ((imm & 0x800) >> 4) | opcode) & 0xFFFFFFFF

    def _assemble_u_type(self, instr_name: str, line: str, spec: tuple) -> int:
        """Assemble and encode U-type: rd, imm"""
        operands = self._parse_operands(line, 2)
        rd, imm = self._parse_register(operands[0]), self._parse_immediate(operands[1])
        self._validate_regs(rd)
        opcode = spec[0]
        return ((((imm >> 12) & 0xFFFFF) << 12) | (rd << 7) | opcode) & 0xFFFFFFFF

    def _assemble_j_type(self, instr_name: str, line: str, spec: tuple) -> int:
        """Assemble and encode J-type: rd, offset"""
        operands = self._parse_operands(line, 2)
        rd, offset = self._parse_register(operands[0]), self._parse_immediate(operands[1])
        self._validate_regs(rd)
        opcode = spec[0]
        imm = self._sign_extend(offset, 21)
        return (((imm & 0x100000) << 11) | (((imm >> 1) & 0x3FF) << 21) | 
                (((imm >> 11) & 0x1) << 20) | (((imm >> 12) & 0xFF) << 12) | (rd << 7) | opcode) & 0xFFFFFFFF

    # ==================== MAIN COMPILATION INTERFACE ====================
    def assemble_instruction(self, line: str) -> Optional[int]:
        """Assemble single instruction. Returns None for empty lines."""
        if '#' in line:
            line = line[:line.index('#')]
        line = line.strip()
        if not line:
            return None
        
        instr_name = line.split()[0].lower()
        if instr_name not in self.INSTRUCTION_SPECS:
            raise ValueError(f"Unknown instruction: {instr_name}")
        
        instr_type = self._get_instruction_type(instr_name)
        if not instr_type:
            raise ValueError(f"Unknown type for: {instr_name}")
        
        assembler = self.assemblers[instr_type]
        spec = self.INSTRUCTION_SPECS[instr_name]
        return assembler(instr_name, line, spec)

    def compile(self, file_path: str) -> Optional[list]:
        """
        Compile an assembly file into machine code.
        Returns a list of 32-bit integers representing machine code, or None if errors occurred.
        """
        if not os.path.exists(file_path):
            print(f"Error: File '{file_path}' not found")
            return None

        with open(file_path, 'r') as f:
            lines = f.readlines()

        machine_code, errors = [], []
        for line_num, line in enumerate(lines, 1):
            try:
                code = self.assemble_instruction(line)
                if code is not None:
                    machine_code.append(code)
            except Exception as e:
                errors.append(f"Line {line_num}: {e}")

        if errors:
            print("\n=== COMPILATION ERRORS ===")
            for error in errors:
                print(f"  {error}")
            return None

        return machine_code


# ==================== COMMAND LINE INTERFACE ====================
def main() -> None:
    """Main entry point - optional CLI for standalone use."""
    if len(sys.argv) < 2:
        print("RISC-V Assembler Compiler")
        print("Usage: python compiler.py <input_file> [output_file]")
        sys.exit(0)
    
    input_file = sys.argv[1]
    output_file = sys.argv[2] if len(sys.argv) > 2 else (
        input_file[:-4] + '.hex' if input_file.endswith(('.asm', '.s')) else input_file + '.hex'
    )
    
    if not os.path.exists(input_file):
        print(f"Error: Input file not found: {input_file}")
        sys.exit(1)
    
    compiler = RISCVCompiler()
    machine_code = compiler.compile(input_file)
    
    if machine_code is None:
        sys.exit(1)
    
    try:
        with open(output_file, 'w') as f:
            for code in machine_code:
                f.write(f"{code:08X}\n")
        print(f"\n=== COMPILATION SUCCESSFUL ===\nAssembled {len(machine_code)} instructions\nOutput: {output_file}")
        sys.exit(0)
    except IOError as e:
        print(f"Error writing output file: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
