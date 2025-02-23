import os

def create_svg_files(base_directory, svg_content):
    try:
        # List all subdirectories in the given directory
        for folder_name in os.listdir(base_directory):
            folder_path = os.path.join(base_directory, folder_name)
            
            # Check if it's a directory
            if os.path.isdir(folder_path):
                svg_filename = f"{folder_name}.svg"
                svg_filepath = os.path.join(folder_path, svg_filename)
                
                # Create the SVG file with the given content
                with open(svg_filepath, "w", encoding="utf-8") as svg_file:
                    svg_file.write(svg_content.replace("{folder_name}", folder_name))
                
                print(f"Created: {svg_filepath}")
    except Exception as e:
        print(f"Error: {e}")

# Example usage
base_directory = "force-app/main/default/lwc"  # Replace with the actual path
svg_content = """
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 80 80" fill="none">
  <defs>
    <linearGradient id="grad" x1="0%" y1="0%" x2="100%" y2="0%">
      <stop offset="0%" style="stop-color:#FF5733;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#FFC300;stop-opacity:1" />
    </linearGradient>
  </defs>
  <circle cx="40" cy="40" r="30" stroke="url(#grad)" stroke-width="4" fill="none" />
  <path d="M20 40 L40 15 L60 40" stroke="url(#grad)" stroke-width="4" fill="none" stroke-linecap="round" />
</svg>
"""

create_svg_files(base_directory, svg_content)
