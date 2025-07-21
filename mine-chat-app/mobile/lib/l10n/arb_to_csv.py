import json
import csv
import sys
import os

def arb_to_csv(arb_path, csv_path):
    # Abrir el archivo ARB (es un JSON)
    with open(arb_path, 'r', encoding='utf-8') as arb_file:
        data = json.load(arb_file)

    # Solo las claves que NO empiezan por @ (comentarios/metadatos)
    filtered = {k: v for k, v in data.items() if not k.startswith('@')}

    # Escribir a CSV
    with open(csv_path, 'w', encoding='utf-8', newline='') as csv_file:
        writer = csv.writer(csv_file)
        writer.writerow(['key', 'value'])  # Cabecera
        for k, v in filtered.items():
            writer.writerow([k, v])

    print(f'Listo: {len(filtered)} filas exportadas a {csv_path}')

if __name__ == "__main__":
    # Uso: python arb_to_csv.py input.arb output.csv
    if len(sys.argv) < 3:
        print("Uso: python arb_to_csv.py archivo_entrada.arb archivo_salida.csv")
        sys.exit(1)
    arb_path = sys.argv[1]
    csv_path = sys.argv[2]
    if not os.path.exists(arb_path):
        print(f"No existe el archivo {arb_path}")
        sys.exit(1)
    arb_to_csv(arb_path, csv_path)
