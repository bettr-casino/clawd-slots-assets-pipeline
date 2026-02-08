import os
import glob

# Check yt directory structure
base_path = '/workspaces/clawd-slots-assets-pipeline'
yt_path = os.path.join(base_path, 'yt')

print(f"Checking paths...")
print(f"Base path exists: {os.path.exists(base_path)}")
print(f"YT path exists: {os.path.exists(yt_path)}")

if os.path.exists(yt_path):
    print(f"\nContents of {yt_path}:")
    for item in os.listdir(yt_path):
        item_path = os.path.join(yt_path, item)
        print(f"  {'[DIR]' if os.path.isdir(item_path) else '[FILE]'} {item}")
        
        # Check for frames subdirectory
        if os.path.isdir(item_path):
            frames_path = os.path.join(item_path, 'frames')
            if os.path.exists(frames_path):
                print(f"    -> frames/ exists")
                frames = os.listdir(frames_path)
                print(f"       Contains {len(frames)} files")
                for f in frames[:10]:
                    print(f"         - {f}")

# Search for any png/jpg files anywhere
print(f"\nSearching for all image files...")
for root, dirs, files in os.walk(base_path):
    for file in files:
        if file.endswith(('.png', '.jpg', '.jpeg', '.webp')):
            print(f"  {os.path.join(root, file)}")
