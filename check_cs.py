from pypdf import PdfReader
import re

reader = PdfReader('/mnt/c/Users/DELL/Downloads/majid-et-al-2026-effect-of-bed-roughness-on-pressure-flow-due-to-vertical-contraction.pdf')

print("Searching paper for roughness constants and wall function details...")
for idx, page in enumerate(reader.pages):
    text = page.extract_text()
    if 'Nikuradse' in text or 'equivalent' in text or 'roughness constant' in text or 'roughness parameter' in text:
        print(f"--- Page {idx+1} ---")
        lines = text.split('\n')
        for line in lines:
            if any(w in line.lower() for w in ['nikuradse', 'equivalent', 'roughness', 'parameter', 'constant']):
                print("  ", line.strip())
