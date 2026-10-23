# Godot instantiates the plugin class by reflection (manifest meta-data) and calls
# its @UsedByGodot methods by name: keep both if the app is ever minified.
-keep class io.github.dasbutterschnitzel.nachhall.ads.NachhallAdsPlugin { *; }
