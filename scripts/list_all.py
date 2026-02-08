import os

# List all files recursively in yt directory
base = "/workspaces/clawd-slots-assets-pipeline"
yt_path = os.path.join(base, "yt")

print(f"Base path: {base}")
print(f"Exists: {os.path.exists(base)}")
print(f"\nListing all files in workspace:")

for root, dirs, files in os.walk(base):
    level = root.replace(base, '').count(os.sep)
    indent = ' ' * 2 * level
    print(f'{indent}{os.path.basename(root)}/')
    subindent = ' ' * 2 * (level + 1)
    for file in files[:20]:  # Limit to avoid too much output
        print(f'{subindent}{file}')
    if len(files) > 20:
        print(f'{subindent}... and {len(files)-20} more files')
