#!/usr/bin/env python3
"""
Analyze extracted slot machine frames using multimodal LLM.
Writes analysis results to analysis.md
"""

import os
import sys
import glob
import base64
from pathlib import Path

# Configuration
FRAMES_DIR = sys.argv[1] if len(sys.argv) > 1 else "yt/CLEOPATRA/frames"
OUTPUT_FILE = Path(FRAMES_DIR).parent / "analysis.md"

def encode_image(image_path):
    """Encode image to base64"""
    with open(image_path, "rb") as f:
        return base64.b64encode(f.read()).decode('utf-8')

def analyze_frames():
    """Analyze all frames in the directory"""
    frames_dir = Path(FRAMES_DIR)
    
    if not frames_dir.exists():
        print(f"Error: Frames directory not found: {frames_dir}")
        sys.exit(1)
    
    # Get all image files
    image_extensions = ['*.png', '*.jpg', '*.jpeg', '*.webp']
    frame_files = []
    for ext in image_extensions:
        frame_files.extend(glob.glob(str(frames_dir / ext)))
    
    if not frame_files:
        print(f"No image files found in {frames_dir}")
        sys.exit(1)
    
    frame_files.sort()
    print(f"Found {len(frame_files)} frames to analyze")
    
    # Build analysis prompt
    analysis_prompt = """Analyze these slot machine video frames and extract detailed information:

## Analysis Requirements

### 1. Symbol Inventory
- List all visible symbols (low, mid, high value)
- Describe each symbol's appearance
- Note any special symbols (Wild, Scatter, Bonus)

### 2. Reel Layout
- Number of reels (columns)
- Number of visible rows per reel
- Total symbol positions visible

### 3. Game Mechanics Observed
- Payline patterns visible
- Any bonus feature triggers
- Animation styles

### 4. Visual Elements
- Background/theme
- UI elements (buttons, displays)
- Text/fonts used

### 5. Math Model Estimates
- Symbol frequencies (if determinable)
- Possible paytable structure
- Volatility indicators

Format as markdown with clear sections. Be specific about what you can see vs. what you're inferring."""

    # Write the prompt and frame list to output
    output = f"""# Slot Machine Frame Analysis

## Source
- Video: CLEOPATRA.webm
- Frames analyzed: {len(frame_files)}
- Frame timestamps: {[Path(f).stem for f in frame_files]}

## Analysis Prompt
{analysis_prompt}

## Frame Files
"""
    for frame in frame_files:
        output += f"- `{Path(frame).name}`\n"
    
    output += """
## Manual Analysis Required

The following analysis requires a multimodal LLM (Kimi K-2.5, Grok Vision, or GPT-4o).

To complete analysis, run:
```python
import openclaw

# Analyze frames with vision model
for frame in frame_files:
    result = openclaw.image.analyze(frame, prompt=analysis_prompt)
    # Append to analysis.md
```

Or manually review frames at:
""" + str(frames_dir) + """

## Frame Previews
"""
    
    # Add base64 encoded images (first few for reference)
    for frame in frame_files[:5]:
        encoded = encode_image(frame)
        output += f"\n### {Path(frame).name}\n"
        output += f"![{Path(frame).name}](data:image/png;base64,{encoded[:200]}...)\n"
    
    # Write output
    with open(OUTPUT_FILE, 'w') as f:
        f.write(output)
    
    print(f"Analysis template written to: {OUTPUT_FILE}")
    print(f"\nNext step: Use a multimodal LLM to analyze these frames")
    return frame_files

if __name__ == "__main__":
    analyze_frames()
