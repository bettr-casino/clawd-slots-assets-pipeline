import os
import glob

# Find all image files in the project
image_files = []
for root, dirs, files in os.walk('/workspaces/clawd-slots-assets-pipeline'):
    for file in files:
        if file.endswith(('.png', '.jpg', '.jpeg', '.webp')):
            image_files.append(os.path.join(root, file))

print(f"Found {len(image_files)} image files:")
for f in image_files[:20]:
    print(f"  {f}")

# Check yt directory structure
yt_dir = '/workspaces/clawd-slots-assets-pipeline/yt'
if os.path.exists(yt_dir):
    print(f"\nContents of {yt_dir}:")
    for item in os.listdir(yt_dir):
        print(f"  {item}")
else:
    print(f"\n{yt_dir} does not exist")
