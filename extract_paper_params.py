from pypdf import PdfReader
import re

reader = PdfReader('/mnt/c/Users/DELL/Downloads/majid-et-al-2026-effect-of-bed-roughness-on-pressure-flow-due-to-vertical-contraction.pdf')

print("Searching paper for parameter details...")
keywords = [r'roughness\s+height', r'k_s', r'ks', r'd_{50}', r'd50', r'shear\s+stress', r'wall\s+function', r'velocity', r'discharge', r'slope']

for idx, page in enumerate(reader.pages):
    text = page.extract_text()
    for kw in keywords:
        matches = list(re.finditer(kw, text, re.IGNORECASE))
        if matches:
            print(f"--- Page {idx+1} Match for '{kw}' ---")
            for m in matches:
                start = max(0, m.start() - 150)
                end = min(len(text), m.end() + 150)
                print(f"...{text[start:end].replace(chr(10), ' ')}...")
                print()
