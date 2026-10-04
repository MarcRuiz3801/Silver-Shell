extends ColorRect

# Exportable fade time variable (in seconds)
@export var fade_time: float = 2.0

func _ready():
	# Start fading out immediately when scene loads
	fade_out()

func fade_out():
	# Create a Tween for smooth fading
	var tween = create_tween()
	
	# Store the starting color
	var start_color = color
	
	# Tween the alpha from current value to 0 over fade_time seconds
	tween.tween_property(self, "color:a", 0.0, fade_time)
	
	# Optional: queue free the node after fade completes (uncomment if needed)
	# tween.tween_callback(queue_free)
'''

# Save the script to output directory
with open('output/ColorRectFade.gd', 'w') as f:
    f.write(code)

print("Script saved to output/ColorRectFade.gd")
print(f"Exported variable: fade_time (default: {2.0} seconds)")
'''
