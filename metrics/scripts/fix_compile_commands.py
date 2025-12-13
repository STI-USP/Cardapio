#!/usr/bin/env python3
import json
import os
from pathlib import Path

# Calcula o diretório raiz do projeto com base na localização deste script
ROOT = Path(__file__).resolve().parents[2]
INPUT = ROOT / "compile_commands.json"
OUTPUT = ROOT / "compile_commands.fixed.json"

with open(INPUT, "r", encoding="utf-8") as f:
    data = json.load(f)

fixed = []
fixed_count = 0
skipped_no_file = 0

for entry in data:
    cmd = entry.get("command") or ""
    directory = entry.get("directory") or ""
    file_path = entry.get("file")

    # Normaliza barras invertidas usadas para escapar espaços
    if isinstance(directory, str):
        directory = directory.replace("\\ ", " ")
        entry["directory"] = directory

    if isinstance(file_path, str):
        file_path = file_path.replace("\\ ", " ")
        entry["file"] = file_path

    # Caso 1: file está vazio e directory, na verdade, é um caminho de arquivo (.m/.mm/.h/.c/.cpp)
    if not entry.get("file") and isinstance(directory, str) and directory.endswith((
        ".m", ".mm", ".h", ".hpp", ".c", ".cc", ".cpp"
    )):
        file_path = directory
        entry["file"] = file_path
        entry["directory"] = str(Path(file_path).parent)

    # Caso 2: ainda não temos file, tenta extrair do comando (-c <arquivo>)
    if not entry.get("file") and isinstance(cmd, str):
        parts = cmd.split()
        if "-c" in parts:
            idx = parts.index("-c")
            if idx + 1 < len(parts):
                full_path = parts[idx + 1].replace("\\ ", " ")
                entry["file"] = full_path
                # Se directory não for uma pasta válida, ajusta para a pasta do arquivo
                if not directory or not os.path.isdir(directory):
                    entry["directory"] = str(Path(full_path).parent)

    # Se depois de todos os ajustes ainda não há arquivo, descarta a entrada
    if entry.get("file"):
        fixed.append(entry)
        fixed_count += 1
    else:
        skipped_no_file += 1

with open(OUTPUT, "w", encoding="utf-8") as f:
    json.dump(fixed, f, indent=2)

print(f"Input commands: {len(data)}")
print(f"Written commands: {len(fixed)}")
print(f"Skipped (no file): {skipped_no_file}")
print(f"Output: {OUTPUT}")
