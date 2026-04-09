#!/usr/bin/env python3
"""
Script pour convertir les fiches Markdown des indicateurs PMSI en format JSON.
Ce format est optimisé pour une intégration dans un agent Mistral.
"""

import json
import os
import re

def parse_markdown_to_json(md_file):
    """
    Parse a Markdown file into a structured JSON format.
    
    Args:
        md_file (str): Path to the Markdown file.
    
    Returns:
        dict: Structured data for the indicator.
    """
    with open(md_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Extract title (first # header)
    title_match = re.search(r'^#\s+(.*?)\s*$', content, re.MULTILINE)
    title = title_match.group(1) if title_match else "Unknown"
    
    # Initialize data structure
    data = {
        "indicateur": title,
        "definition": "",
        "calcul": "",
        "utilite": [],
        "sources": [],
        "exemples": [],
        "limites": [],
        "references": []
    }
    
    # Extract sections
    sections = re.split(r'^##\s+(.*?)\s*$', content, flags=re.MULTILINE)[1:]
    sections = dict(zip(sections[::2], sections[1::2]))
    
    # Fill data structure
    for section_name, section_content in sections.items():
        # Clean content: remove code blocks and extra whitespace
        cleaned_content = re.sub(r'```.*?```', '', section_content, flags=re.DOTALL)
        cleaned_content = re.sub(r'\n', ' ', cleaned_content.strip())
        cleaned_content = re.sub(r'\s+', ' ', cleaned_content)
        
        if section_name.lower() == "définition":
            data["definition"] = cleaned_content
        elif section_name.lower() == "calcul":
            data["calcul"] = cleaned_content
        elif section_name.lower() == "utilité":
            # Extract list items (bullet points)
            items = re.findall(r'-\s*(.*?)(?=-\s*|$)', section_content)
            data["utilite"] = [item.strip() for item in items if item.strip()]
        elif section_name.lower() == "sources de données":
            # Extract list items
            items = re.findall(r'-\s*(.*?)(?=-\s*|$)', section_content)
            data["sources"] = [item.strip() for item in items if item.strip()]
        elif section_name.lower() == "exemple de valeurs":
            # Extract list items
            items = re.findall(r'-\s*(.*?)(?=-\s*|$)', section_content)
            data["exemples"] = [item.strip() for item in items if item.strip()]
        elif section_name.lower() == "limites":
            # Extract list items
            items = re.findall(r'-\s*(.*?)(?=-\s*|$)', section_content)
            data["limites"] = [item.strip() for item in items if item.strip()]
        elif section_name.lower() == "références":
            # Extract list items
            items = re.findall(r'-\s*\[(.*?)\]\((.*?)\)', section_content)
            data["references"] = [{"text": text, "url": url} for text, url in items]
    
    return data

def convert_all_markdown_files(input_dir, output_file):
    """
    Convert all Markdown files in a directory to a single JSON file.
    
    Args:
        input_dir (str): Directory containing Markdown files.
        output_file (str): Path to the output JSON file.
    """
    indicators = []
    
    for filename in os.listdir(input_dir):
        if filename.endswith('.md'):
            md_path = os.path.join(input_dir, filename)
            indicator_data = parse_markdown_to_json(md_path)
            indicators.append(indicator_data)
    
    # Write to JSON file
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(indicators, f, indent=2, ensure_ascii=False)
    
    print(f"Conversion terminée. {len(indicators)} indicateurs convertis dans {output_file}.")

if __name__ == "__main__":
    INPUT_DIR = "indicateurs_pmsi"
    OUTPUT_FILE = "pmsi_indicateurs.json"
    
    convert_all_markdown_files(INPUT_DIR, OUTPUT_FILE)
